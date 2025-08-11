/**
 * SGIME - Sistema de Gestão Integrada de Melhorias e Eficiência
 * Colégio Pedro II - JavaScript Customizado - Versão 2.0
 * Funcionalidades específicas e melhorias de UX para o CPII
 */

(function($) {
  'use strict';

  // Namespace SGIME - Colégio Pedro II
  window.SGIME = window.SGIME || {};
  window.CPII = window.CPII || {}; // Namespace específico do Colégio Pedro II

  /**
   * Configurações globais do CPII
   */
  SGIME.config = {
    animationDuration: 300,
    toastDuration: 4000,
    version: '2.0.0-cpii',
    institution: 'Colégio Pedro II',
    colors: {
      primary: '#003366',
      secondary: '#DAA520',
      light: '#F4E4BC'
    }
  };

  /**
   * Utilitários gerais do CPII
   */
  SGIME.utils = {
    
    /**
     * Exibe notificação toast com estilo CPII
     */
    showToast: function(message, type = 'info') {
      const toastClass = {
        'success': 'toast-success cpii-toast',
        'error': 'toast-error cpii-toast',
        'warning': 'toast-warning cpii-toast',
        'info': 'toast-info cpii-toast'
      }[type] || 'toast-info cpii-toast';

      const toast = $(`
        <div class="sgime-toast ${toastClass}">
          <div class="toast-content">
            <span class="toast-icon">${this.getToastIcon(type)}</span>
            <span class="toast-message">${message}</span>
            <button class="toast-close">&times;</button>
          </div>
        </div>
      `);

      $('body').append(toast);
      
      setTimeout(() => {
        toast.addClass('show');
      }, 10);

      // Auto remove
      setTimeout(() => {
        this.removeToast(toast);
      }, SGIME.config.toastDuration);

      // Manual close
      toast.find('.toast-close').on('click', () => {
        this.removeToast(toast);
      });
    },

    /**
     * Remove toast
     */
    removeToast: function(toast) {
      toast.removeClass('show');
      setTimeout(() => {
        toast.remove();
      }, SGIME.config.animationDuration);
    },

    /**
     * Retorna ícone para toast
     */
    getToastIcon: function(type) {
      const icons = {
        'success': '✓',
        'error': '✗',
        'warning': '⚠',
        'info': 'ℹ'
      };
      return icons[type] || icons.info;
    },

    /**
     * Confirma ação com modal customizado
     */
    confirm: function(message, callback) {
      const modal = $(`
        <div class="sgime-modal-overlay">
          <div class="sgime-modal">
            <div class="modal-header">
              <h3>Confirmação</h3>
            </div>
            <div class="modal-body">
              <p>${message}</p>
            </div>
            <div class="modal-footer">
              <button class="button button-negative modal-cancel">Cancelar</button>
              <button class="button button-positive modal-confirm">Confirmar</button>
            </div>
          </div>
        </div>
      `);

      $('body').append(modal);
      
      setTimeout(() => {
        modal.addClass('show');
      }, 10);

      modal.find('.modal-confirm').on('click', () => {
        this.closeModal(modal);
        if (callback) callback(true);
      });

      modal.find('.modal-cancel, .sgime-modal-overlay').on('click', (e) => {
        if (e.target === e.currentTarget) {
          this.closeModal(modal);
          if (callback) callback(false);
        }
      });
    },

    /**
     * Fecha modal
     */
    closeModal: function(modal) {
      modal.removeClass('show');
      setTimeout(() => {
        modal.remove();
      }, SGIME.config.animationDuration);
    },

    /**
     * Formata data brasileira
     */
    formatDateBR: function(date) {
      return new Date(date).toLocaleDateString('pt-BR');
    },

    /**
     * Debounce function
     */
    debounce: function(func, wait) {
      let timeout;
      return function executedFunction(...args) {
        const later = () => {
          clearTimeout(timeout);
          func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
      };
    }
  };

  /**
   * Melhorias na interface
   */
  SGIME.ui = {
    
    /**
     * Inicializa melhorias gerais
     */
    init: function() {
      this.setupAnimations();
      this.setupEnhancedForms();
      this.setupTableEnhancements();
      this.setupSearchEnhancements();
      this.setupTooltips();
      this.setupKeyboardShortcuts();
    },

    /**
     * Configura animações
     */
    setupAnimations: function() {
      // Adiciona classe fade-in aos elementos principais
      $('#content > *').addClass('fade-in');
      
      // Anima carregamento de tabelas
      $('table.list').each(function() {
        $(this).find('tr').each(function(index) {
          $(this).css('animation-delay', (index * 50) + 'ms');
          $(this).addClass('slide-in');
        });
      });
    },

    /**
     * Melhora formulários
     */
    setupEnhancedForms: function() {
      // Auto-focus no primeiro campo
      $('form input:visible:first').focus();

      // Validação em tempo real
      $('input[required]').on('blur', function() {
        const $this = $(this);
        if (!$this.val().trim()) {
          $this.addClass('error');
        } else {
          $this.removeClass('error');
        }
      });

      // Salvar rascunho automaticamente
      const autosave = SGIME.utils.debounce(function() {
        const formData = {};
        $('form textarea, form input[type="text"]').each(function() {
          if ($(this).attr('name')) {
            formData[$(this).attr('name')] = $(this).val();
          }
        });
        localStorage.setItem('sgime_draft_' + window.location.pathname, JSON.stringify(formData));
      }, 2000);

      $('form textarea, form input[type="text"]').on('input', autosave);

      // Restaurar rascunho
      this.restoreDraft();
    },

    /**
     * Restaura rascunho salvo
     */
    restoreDraft: function() {
      const draftKey = 'sgime_draft_' + window.location.pathname;
      const draft = localStorage.getItem(draftKey);
      
      if (draft) {
        try {
          const formData = JSON.parse(draft);
          Object.keys(formData).forEach(name => {
            const $field = $(`[name="${name}"]`);
            if ($field.length && !$field.val()) {
              $field.val(formData[name]);
            }
          });
          
          SGIME.utils.showToast('Rascunho restaurado automaticamente', 'info');
        } catch (e) {
          localStorage.removeItem(draftKey);
        }
      }
    },

    /**
     * Melhora tabelas
     */
    setupTableEnhancements: function() {
      // Ordenação visual
      $('table.list th').addClass('sortable').on('click', function() {
        $(this).toggleClass('sorted-asc sorted-desc');
      });

      // Highlight de linha ao hover
      $('table.list tr').on('mouseenter', function() {
        $(this).addClass('highlight');
      }).on('mouseleave', function() {
        $(this).removeClass('highlight');
      });

      // Checkbox master para seleção múltipla
      if ($('table.list input[type="checkbox"]').length > 1) {
        const $masterCheckbox = $('<input type="checkbox" class="master-checkbox">');
        $('table.list th:first').prepend($masterCheckbox);
        
        $masterCheckbox.on('change', function() {
          $('table.list input[type="checkbox"]').prop('checked', $(this).prop('checked'));
        });
      }
    },

    /**
     * Melhora busca
     */
    setupSearchEnhancements: function() {
      // Busca instantânea
      const searchInput = $('#q, input[name="q"]');
      if (searchInput.length) {
        const searchHandler = SGIME.utils.debounce(function() {
          // Implementar busca AJAX aqui se necessário
          console.log('Busca:', searchInput.val());
        }, 500);

        searchInput.on('input', searchHandler);
      }
    },

    /**
     * Configura tooltips
     */
    setupTooltips: function() {
      $('[title]').each(function() {
        const $this = $(this);
        const title = $this.attr('title');
        
        $this.removeAttr('title').on('mouseenter', function(e) {
          const tooltip = $(`<div class="sgime-tooltip">${title}</div>`);
          $('body').append(tooltip);
          
          const offset = $this.offset();
          tooltip.css({
            top: offset.top - tooltip.outerHeight() - 10,
            left: offset.left + ($this.outerWidth() / 2) - (tooltip.outerWidth() / 2)
          }).addClass('show');
          
          $this.data('tooltip', tooltip);
        }).on('mouseleave', function() {
          const tooltip = $this.data('tooltip');
          if (tooltip) {
            tooltip.removeClass('show');
            setTimeout(() => tooltip.remove(), 200);
          }
        });
      });
    },

    /**
     * Atalhos do teclado
     */
    setupKeyboardShortcuts: function() {
      $(document).on('keydown', function(e) {
        // Ctrl/Cmd + S para salvar
        if ((e.ctrlKey || e.metaKey) && e.key === 's') {
          e.preventDefault();
          const submitBtn = $('input[type="submit"], button[type="submit"]').first();
          if (submitBtn.length) {
            submitBtn.click();
            SGIME.utils.showToast('Salvando...', 'info');
          }
        }
        
        // Escape para cancelar
        if (e.key === 'Escape') {
          $('.sgime-modal-overlay').each(function() {
            SGIME.utils.closeModal($(this));
          });
        }
      });
    }
  };

  /**
   * Dashboard específico
   */
  SGIME.dashboard = {
    
    init: function() {
      this.setupWidgets();
      this.setupCharts();
      this.updateCounters();
    },

    setupWidgets: function() {
      $('.sgime-widget').each(function() {
        $(this).addClass('fade-in');
      });
    },

    setupCharts: function() {
      // Placeholder para gráficos futuros
      console.log('SGIME Dashboard: Charts ready');
    },

    updateCounters: function() {
      $('.counter').each(function() {
        const $this = $(this);
        const target = parseInt($this.text());
        let current = 0;
        
        const increment = target / 20;
        const timer = setInterval(() => {
          current += increment;
          if (current >= target) {
            current = target;
            clearInterval(timer);
          }
          $this.text(Math.floor(current));
        }, 50);
      });
    }
  };

  /**
   * Inicialização quando o DOM estiver pronto
   */
  $(document).ready(function() {
    console.log('SGIME JS loaded - Version:', SGIME.config.version);
    
    // Inicializar componentes
    SGIME.ui.init();
    
    // Inicializar dashboard se estiver na página
    if ($('.sgime-dashboard').length || $('body').hasClass('controller-my')) {
      SGIME.dashboard.init();
    }

    // Mensagem de boas-vindas (apenas uma vez por sessão)
    if (!sessionStorage.getItem('sgime_welcome_shown')) {
      setTimeout(() => {
        SGIME.utils.showToast('Bem-vindo ao SGIME! 🏢', 'success');
        sessionStorage.setItem('sgime_welcome_shown', 'true');
      }, 1000);
    }

    // Interceptar formulários para melhor UX
    $('form').on('submit', function() {
      const submitBtn = $(this).find('input[type="submit"], button[type="submit"]');
      submitBtn.prop('disabled', true).val('Processando...');
      
      setTimeout(() => {
        submitBtn.prop('disabled', false).val('Salvar');
      }, 3000);
    });

    // Limpeza de rascunhos antigos
    Object.keys(localStorage).forEach(key => {
      if (key.startsWith('sgime_draft_') && Math.random() < 0.1) {
        // 10% de chance de limpar rascunhos antigos
        localStorage.removeItem(key);
      }
    });

    // Marcar a Home quando o link do header for exatamente "Redmine" para o CSS pintar "SGIME"
    const $headerLink = $('#header h1 a').first();
    if ($headerLink.length) {
      const baseText = ($headerLink.text() || '').replace(/[\u2000-\u200F\u202F\u205F\u00A0]/g, ' ').trim();
      if (/^Redmine$/i.test(baseText)) {
        $headerLink.attr('data-sgime-home', 'true');
      } else {
        $headerLink.removeAttr('data-sgime-home');
      }
    }

    // Ajuste de posicionamento do autocomplete "Adicionar:" na Minha Página
    const adjustAutocompleteEdge = function($menu) {
      try {
        const rect = $menu[0].getBoundingClientRect();
        const atEdge = rect.right > window.innerWidth - 8;
        if (atEdge) {
          $menu.addClass('is-at-edge');
        } else {
          $menu.removeClass('is-at-edge');
        }
      } catch (_) { /* ignore */ }
    };

    const repositionAutocompleteToInput = function($menu) {
      const el = document.activeElement;
      if (!el || !(el instanceof HTMLElement)) return;
      const inputRect = el.getBoundingClientRect();
      if (!inputRect || !inputRect.width) return;
      // largura mínima igual à do input
      const minWidth = Math.max(220, Math.floor(inputRect.width));
      // calcular esquerda limitada à viewport
      const menuWidth = Math.max(minWidth, $menu.outerWidth() || 0);
      const left = Math.min(inputRect.left, window.innerWidth - menuWidth - 8);
      const top = inputRect.bottom + 4;
      $menu.css({
        position: 'fixed',
        left: left + 'px',
        top: top + 'px',
        minWidth: minWidth + 'px',
        maxWidth: 'calc(100vw - 16px)',
        maxHeight: 'calc(100vh - ' + (top + 16) + 'px)',
        overflow: 'auto'
      });
    };

    $(document).on('menufocus autocompletesearch autocompleteshow autocompleteopen', function() {
      const $menu = $('.ui-autocomplete:visible').last();
      if ($menu.length) {
        adjustAutocompleteEdge($menu);
        repositionAutocompleteToInput($menu);
      }
    });
    $(window).on('resize', function(){
      const $menu = $('.ui-autocomplete:visible').last();
      if ($menu.length) { adjustAutocompleteEdge($menu); repositionAutocompleteToInput($menu); }
    });
  });

})(jQuery);

// CSS adicional via JavaScript
const additionalCSS = `
  .sgime-toast {
    position: fixed;
    top: 20px;
    right: 20px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    padding: 15px;
    max-width: 300px;
    transform: translateX(100%);
    transition: transform 0.3s ease;
    z-index: 10000;
    border-left: 4px solid var(--sgime-primary);
  }
  
  .sgime-toast.show {
    transform: translateX(0);
  }
  
  .sgime-toast.toast-success { border-left-color: var(--sgime-secondary); }
  .sgime-toast.toast-error { border-left-color: var(--sgime-danger); }
  .sgime-toast.toast-warning { border-left-color: var(--sgime-warning); }
  
  .toast-content {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .toast-close {
    background: none;
    border: none;
    font-size: 18px;
    cursor: pointer;
    margin-left: auto;
  }
  
  .sgime-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 10001;
    opacity: 0;
    transition: opacity 0.3s ease;
  }
  
  .sgime-modal-overlay.show {
    opacity: 1;
  }
  
  .sgime-modal {
    background: white;
    border-radius: 8px;
    max-width: 500px;
    width: 90%;
    transform: scale(0.9);
    transition: transform 0.3s ease;
  }
  
  .sgime-modal-overlay.show .sgime-modal {
    transform: scale(1);
  }
  
  .modal-header, .modal-body, .modal-footer {
    padding: 20px;
  }
  
  .modal-header {
    border-bottom: 1px solid var(--sgime-gray-300);
  }
  
  .modal-footer {
    border-top: 1px solid var(--sgime-gray-300);
    display: flex;
    gap: 10px;
    justify-content: flex-end;
  }
  
  .sgime-tooltip {
    position: absolute;
    background: var(--sgime-gray-800);
    color: white;
    padding: 8px 12px;
    border-radius: 4px;
    font-size: 12px;
    z-index: 10002;
    opacity: 0;
    transition: opacity 0.2s ease;
    pointer-events: none;
  }
  
  .sgime-tooltip.show {
    opacity: 1;
  }
  
  .error {
    border-color: var(--sgime-danger) !important;
    box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.1) !important;
  }
  
  .highlight {
    background: rgba(44, 90, 160, 0.05) !important;
  }
  
  .sortable {
    cursor: pointer;
    user-select: none;
  }
  
  .sortable:hover {
    background: rgba(44, 90, 160, 0.1);
  }
  
  .sorted-asc::after {
    content: " ▲";
  }
  
  .sorted-desc::after {
    content: " ▼";
  }
`;

// Inject CSS
const style = document.createElement('style');
style.textContent = additionalCSS;
document.head.appendChild(style);

  /**
   * Funcionalidades específicas do Colégio Pedro II
   */
  window.CPII = {
    
    /**
     * Inicializa funcionalidades específicas do CPII
     */
    init: function() {
      this.addInstitutionalElements();
      this.enhanceNavigation();
      this.addCPIIBranding();
      this.initAccessibility();
      
      console.log('SGIME CPII v' + SGIME.config.version + ' inicializado');
      SGIME.utils.showToast('Sistema SGIME do Colégio Pedro II carregado!', 'success');
    },
    
    /**
     * Adiciona elementos institucionais do CPII
     */
    addInstitutionalElements: function() {
      // Adiciona brasão ao header se não existir
      if ($('#header .header-identity').length === 0 && $('#header h1').length > 0) {
        $('#header h1').wrap('<div class="header-identity"></div>');
      }
      
      // Adiciona informações institucionais ao footer
      const footerInfo = `
        <div class="cpii-footer-info">
          <p><strong>Colégio Pedro II</strong> - Campo de São Cristóvão, 177 - São Cristóvão - RJ</p>
          <p>Sistema SGIME - Gestão Integrada de Melhorias e Eficiência</p>
        </div>
      `;
      
      if ($('#footer .cpii-footer-info').length === 0) {
        $('#footer').append(footerInfo);
      }
    },
    
    /**
     * Melhora a navegação com identidade CPII
     */
    enhanceNavigation: function() {
      // Ícones consistentes no menu principal (todos os botões da mesma linha)
      const menuIcons = {
        'Página inicial': '🏠',
        'Minha página': '🏡',
        'Projetos': '📁',
        'Usuários': '👥',
        'Administração': '⚙️',
        'Ajuda': '❓',
        'Minha conta': '👤',
        'Conta': '👤',
        'Sair': '🔒',
        'Entrar': '🔓',
        'Registrar': '📝'
      };

      const defaultIcon = '🔹';

      $('#top-menu a').each(function() {
        const $link = $(this);
        // Evitar duplicar
        if ($link.find('.cpii-menu-icon').length > 0) return;
        const text = $link.text().trim();
        const icon = menuIcons[text] || defaultIcon;
        $link.prepend('<span class="cpii-menu-icon" aria-hidden="true">' + icon + '</span> ');
      });
    },
    
    /**
     * Adiciona branding do CPII
     */
    addCPIIBranding: function() {
      // Adiciona favicon se suportado
      if (!$('link[rel="icon"]').length) {
        $('head').append('<link rel="icon" type="image/x-icon" href="/plugin_assets/sgime_customizations/images/favicon.ico">');
      }
      
      // Adiciona meta tags institucionais
      if (!$('meta[name="institution"]').length) {
        $('head').append('<meta name="institution" content="Colégio Pedro II">');
        $('head').append('<meta name="system" content="SGIME - Sistema de Gestão Integrada">');
      }
    },
    
    /**
     * Inicializa recursos de acessibilidade
     */
    initAccessibility: function() {
      // Adiciona botão de alto contraste
      const contrastButton = `
        <button id="cpii-contrast-toggle" class="cpii-accessibility-btn" 
                title="Alternar Alto Contraste" aria-label="Alternar Alto Contraste">
          🔆
        </button>
      `;
      
      if ($('#cpii-contrast-toggle').length === 0) {
        $('body').append(contrastButton);
      }
      
      // Funcionalidade do alto contraste
      $(document).on('click', '#cpii-contrast-toggle', function() {
        $('body').toggleClass('cpii-high-contrast');
        const isHighContrast = $('body').hasClass('cpii-high-contrast');
        $(this).text(isHighContrast ? '🔅' : '🔆');
        
        SGIME.utils.showToast(
          isHighContrast ? 'Alto contraste ativado' : 'Alto contraste desativado', 
          'info'
        );
      });
    }
  };

  // CSS específico para alto contraste e acessibilidade
  const accessibilityCSS = `
    .cpii-high-contrast {
      filter: contrast(150%) brightness(90%);
    }
    
    .cpii-high-contrast #header {
      background: #000 !important;
      color: #fff !important;
    }
    
    .cpii-high-contrast .cpii-card {
      border: 3px solid #000 !important;
      background: #fff !important;
    }
    
    .cpii-accessibility-btn {
      position: fixed;
      top: 10px;
      right: 10px;
      z-index: 9999;
      background: var(--cp2-dourado);
      border: 2px solid var(--cp2-azul-institucional);
      color: var(--cp2-azul-institucional);
      padding: 8px;
      border-radius: 50%;
      cursor: pointer;
      font-size: 16px;
      width: 40px;
      height: 40px;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s ease;
    }
    
    .cpii-accessibility-btn:hover {
      transform: scale(1.1);
      box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    }
    
    .cpii-footer-info {
      margin-top: 1rem;
      padding-top: 1rem;
      border-top: 1px solid var(--cp2-dourado);
      text-align: center;
    }
    
    .cpii-footer-info p {
      margin: 0.5rem 0;
      font-size: 0.9rem;
    }
  `;
  
  // Adiciona CSS de acessibilidade
  const accessibilityStyle = document.createElement('style');
  accessibilityStyle.id = 'cpii-accessibility-styles';
  accessibilityStyle.textContent = accessibilityCSS;
  document.head.appendChild(accessibilityStyle);

  // Inicialização quando o documento estiver pronto  
  $(document).ready(function() {
    SGIME.init();
    if (window.CPII) {
      CPII.init();
    }
  });

  /**
   * Correções finais da identidade CPII
   */
  CPII.finalizeIdentity = function() {
    // Título da página: apenas prefixo institucional
    if (!document.title.includes('SGIME')) {
      document.title = 'SGIME - Colégio Pedro II :: ' + document.title;
    }

  // Header: não alterar via JS para evitar flashes; a Home é tratada por CSS condicional
    
    // Adicionar favicon se não existir
    if (!$('link[rel="icon"]').length && !$('link[rel="shortcut icon"]').length) {
      $('head').append('<link rel="icon" type="image/x-icon" href="/plugin_assets/sgime_customizations/images/favicon.ico">');
      $('head').append('<link rel="shortcut icon" type="image/x-icon" href="/plugin_assets/sgime_customizations/images/favicon.ico">');
    }
    
    // Garantir que os links do menu superior sejam visíveis
    $('#top-menu ul li').show();
    $('#main-menu ul li').show();
    
    // Adicionar ícones aos links se ainda não tiverem
    this.enhanceNavigation();
  };

  // Executar ajustes quando a página carregar
  $(document).ready(function() {
    setTimeout(function() {
      if (window.CPII) {
        CPII.finalizeIdentity();
      }
    }, 500); // Aguardar um pouco para garantir que tudo carregou
  });

  // Executar também quando navegações AJAX terminarem
  $(document).ajaxComplete(function() {
    if (window.CPII) {
      CPII.finalizeIdentity();
    }
  });
