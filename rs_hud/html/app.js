(function () {
  const resourceName = 'rs_hud';
  const $root = $('#root');
  const $veh = $('#veh');
  const $settings = $('#settings');

  const els = {
    hp: $('#hp'),
    arm: $('#arm'),
    hun: $('#hun'),
    thr: $('#thr'),
    rpm: $('#rpm'),
    fuel: $('#fuel'),
    speedVal: $('#speedVal'),
    speedUnit: $('#speedUnit'),
    gear: $('#gear'),
    seatbelt: $('#seatbelt'),
    talking: $('#talking'),
    voiceMode: $('#voiceMode'),
    clock: $('#clock'),
    street: $('#street'),
    dir: $('#dir')
  };

  const state = {};

  function setFill($el, pct) {
    let value = Math.max(0, Math.min(100, Number(pct) || 0));
    const prev = $el.data('pct');
    if (prev === value) return;
    $el.data('pct', value);
    $el.css('width', value + '%');
  }

  function fadeVisible(isVisible) {
    if (isVisible) {
      $root.removeClass('hidden');
      gsap.to($root[0], { duration: 0.18, opacity: 1, overwrite: true });
    } else {
      gsap.to($root[0], {
        duration: 0.18,
        opacity: 0,
        overwrite: true,
        onComplete: () => $root.addClass('hidden')
      });
    }
  }

  function postCallback(name, body) {
    fetch(`https://${resourceName}/${name}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: body ? JSON.stringify(body) : '{}'
    }).catch(() => {});
  }

  window.addEventListener('message', (event) => {
    const d = event.data || {};
    switch (d.action) {
      case 'visibility':
        fadeVisible(!!d.visible);
        if (typeof d.opacity === 'number') {
          document.documentElement.style.setProperty('--alpha', d.opacity);
        }
        break;
      case 'opacity':
        if (typeof d.opacity === 'number') {
          document.documentElement.style.setProperty('--alpha', d.opacity);
        }
        break;
      case 'safezone':
        if (typeof d.size === 'number') {
          document.documentElement.style.setProperty('--safezone', d.size);
        }
        break;
      case 'vehicleMode':
        $veh.toggleClass('hidden', !d.state);
        break;
      case 'voiceMode':
        if (state.voiceMode !== d.mode) {
          state.voiceMode = d.mode;
          els.voiceMode.text('V: ' + d.mode);
        }
        break;
      case 'voiceTalking':
        els.talking.toggleClass('active', !!d.talking);
        break;
      case 'clock':
        if (state.time !== d.time) {
          state.time = d.time;
          els.clock.text(d.time || '00:00');
        }
        break;
      case 'street':
        if (state.street !== d.street || state.zone !== d.zone) {
          state.street = d.street;
          state.zone = d.zone;
          const zoneLabel = d.zone ? ` (${d.zone})` : '';
          els.street.text(`${d.street || '-'}` + zoneLabel);
        }
        if (state.dir !== d.dir) {
          state.dir = d.dir;
          els.dir.text(d.dir || '-');
        }
        break;
      case 'stats':
        setFill(els.hp, d.hp);
        setFill(els.arm, d.armor);
        els.seatbelt.toggleClass('active', !!d.seatbelt);
        break;
      case 'seatbelt':
        els.seatbelt.toggleClass('active', !!d.state);
        break;
      case 'needs':
        setFill(els.hun, d.hunger);
        setFill(els.thr, d.thirst);
        break;
      case 'veh':
        if (state.speed !== d.speed) {
          state.speed = d.speed;
          els.speedVal.text(d.speed);
        }
        if (state.unit !== d.unit) {
          state.unit = d.unit;
          els.speedUnit.text(d.unit);
        }
        setFill(els.rpm, d.rpm);
        setFill(els.fuel, d.fuel);
        if (state.gear !== d.gear) {
          state.gear = d.gear;
          els.gear.text('G:' + d.gear);
        }
        break;
      case 'openSettings':
        $settings.removeClass('hidden');
        break;
    }
  });

  $('#closeSettings').on('click', function () {
    $settings.addClass('hidden');
    postCallback('closeSettings');
  });

  window.addEventListener('load', function () {
    postCallback('ready');
  });
})();
