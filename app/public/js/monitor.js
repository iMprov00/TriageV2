class PatientMonitor {
  constructor() {
    this.monitorElement = document.getElementById('patients-monitor');
    this.lastUpdatedElement = document.getElementById('last-updated');
    this.updateInterval = null;
    this.init();
  }

  init() {
    this.updateMonitor();
    this.startAutoUpdate();
    this.setupEventListeners();
  }

  async updateMonitor() {
    try {
      const response = await fetch('/beds/data');
      const patients = await response.json();
      this.updateLastUpdated();
      this.renderPatients(patients);
    } catch (error) {
      console.error('Ошибка загрузки данных:', error);
      this.showError();
    }
  }

  renderPatients(patients) {
    if (patients.length === 0) {
      this.showEmptyState();
      return;
    }

    const html = patients.map(patient => this.createPatientCard(patient)).join('');
    this.monitorElement.innerHTML = `
      <div class="monitor-grid">
        ${html}
      </div>
    `;
  }

  createPatientCard(patient) {
    const timeLeft = patient.time_left;
    const isCritical = timeLeft.critical && !timeLeft.expired;
    const isExpired = timeLeft.expired;
    
    const cardClass = `patient-card priority-${patient.priority} ${
      isCritical ? 'critical' : ''} ${isExpired ? 'expired' : ''}`;

    const timerClass = `timer ${isCritical ? 'critical' : ''} ${isExpired ? 'expired' : ''}`;
    
    const timeText = isExpired ? 'ВРЕМЯ ВЫШЛО' : 
      `${timeLeft.minutes.toString().padStart(2, '0')}:${timeLeft.seconds.toString().padStart(2, '0')}`;

    const statusText = isExpired ? 'ТРЕБУЕТСЯ НЕМЕДЛЕННОЕ ВНИМАНИЕ!' :
                   isCritical ? 'КРИТИЧЕСКОЕ ВРЕМЯ!' : '';

    const statusClass = isExpired ? 'status expired' : 
                     isCritical ? 'status critical' : '';

    return `
      <div class="${cardClass}">
        <div class="card-header">
          <h3 class="patient-name">${patient.full_name}</h3>
          <span class="priority-badge">Приоритет ${patient.priority}</span>
        </div>
        
        <div class="card-body">
          <div class="admission-time">
            Поступление: ${new Date(patient.admission_time).toLocaleString('ru-RU')}
          </div>
          
          <div class="timer-container">
            <div class="${timerClass}">${timeText}</div>
            <div class="time-label">Осталось времени</div>
          </div>
        </div>

        ${statusText ? `
          <div class="${statusClass}">
            ${statusText}
          </div>
        ` : ''}
      </div>
    `;
  }

  showEmptyState() {
    this.monitorElement.innerHTML = `
      <div class="empty-state">
        <div class="empty-icon">📋</div>
        <h3>Нет пациентов на мониторинге</h3>
        <p>Добавьте пациентов через систему управления</p>
      </div>
    `;
  }

  showError() {
    this.monitorElement.innerHTML = `
      <div class="error-state">
        <div class="error-icon">⚠️</div>
        <h3>Ошибка загрузки данных</h3>
        <p>Проверьте соединение и попробуйте снова</p>
        <button class="btn-retry" onclick="monitor.updateMonitor()">Повторить попытку</button>
      </div>
    `;
  }

  updateLastUpdated() {
    const now = new Date();
    if (this.lastUpdatedElement) {
      this.lastUpdatedElement.textContent = `Последнее обновление: ${now.toLocaleTimeString('ru-RU')}`;
    }
  }

  startAutoUpdate() {
    this.updateInterval = setInterval(() => {
      this.updateMonitor();
    }, 5000);
  }

  setupEventListeners() {
    // Дополнительные обработчики событий при необходимости
  }

  destroy() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
    }
  }
}

// Инициализация мониторинга при загрузке страницы
document.addEventListener('DOMContentLoaded', function() {
  window.monitor = new PatientMonitor();
});

// Глобальные функции для ручного управления
function refreshMonitor() {
  if (window.monitor) {
    window.monitor.updateMonitor();
  }
}

function toggleFullscreen() {
  if (!document.fullscreenElement) {
    document.documentElement.requestFullscreen().catch(err => {
      console.error('Ошибка полноэкранного режима:', err);
    });
  } else {
    document.exitFullscreen();
  }
}