var phx = {
  lastPill: null,
  lastPillId: -1,
  pickPill: function(pill, id){
    if(this.lastPill){
        this.lastPill.removeClassName("selected");
    }
    pill.addClassName("selected");
    this.lastPill = pill
    this.lastPillId = id;
  },

  lastPatient: null,
  lastPatientId: -1,
  pickPatient: function(patient, id){
    if(this.lastPatient){
        this.lastPatient.removeClassName("selected");
        //# $('patient-info-window-'+ String(lastPatientId)).hide();
    }
    patient.addClassName("selected");
	//# $('patient-info-window-'+ String(lastPatientId)).show();
    this.lastPatient = patient
    this.lastPatientId = id;
  },

  prescribe: function(){
    msg = document.getElementById("messages");
    msg.setInnerFBML(messages.empty);
    if(this.lastPill && this.lastPatient){
      var dialog = new Dialog(Dialog.DIALOG_POP);
      dialog.showChoice('Prescription', dialogs.prescribe, 'Yes', 'Cancel');
      dialog.onconfirm = function() { 
        var ajax = new Ajax();
        ajax.responseType = Ajax.FBML
        ajax.ondone = function(data) {
          /*
          if(data.valid){
            msg.setInnerFBML(messages.validPrescription);
          } else {
            msg.setInnerFBML(messages.invalidPrescription);
          }
          */
          
          phx.rmPatient(phx.lastPatient);
          phx.newPatient(data)

          console.log("valid: "+prescriptionvalid);
        }
        ajax.requireLogin=true;

        ajax.post('CALLBACK_URL/game/prescribed/'+ phx.lastPatientId , "pi=" + phx.lastPillId);
      };
    } else {
      msg.setInnerFBML(messages.pleasePick);
    }
  },

  rmPatient: function(patient){
    Animation(patient).to('opacity', 0).hide().go();
  },

  newPatient: function(templ){
    l = document.getElementById("patientList");
    d = document.createElement("div");
    d.setInnerFBML(templ);
    l.appendChild(d);
  }
}
