export default {
  defaultTemplateId: 'default', //This is the default template for 2 args1
  defaultAltTemplateId: 'defaultAlt', //This one for 1 arg
  templates: { //You can add static templates here'default': '<div style="padding: 10px; margin: 5px; background-color: rgba(60, 160, 255, 0.7); border-radius: 3px;"><strong>OOC {0}</strong>: {1}</div>',
    'looc': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(62, 71, 71); background: rgba(62, 71, 71, 0.75);"><strong>LOOC {0}</strong>: {1}</div>',
    'ooc': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(67, 93, 105); background: rgba(67, 93, 105, 0.75);"><strong>OOC {0}</strong>: {1}</div>',
    'me': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(26, 23, 185); background: rgba(26, 23, 185, 0.75);"><strong>ME</strong> {0}</div>',
    'do': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(124, 106, 0); background: rgba(124, 106, 0, 0.75);"><strong>DO</strong> {0}</div>',
    'try': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(99, 175, 0); background: rgba(99, 175, 0, 0.75);"><strong>TRY</strong> {0}</div>',
    'doc': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(124, 106, 0); background: rgba(124, 106, 0, 0.75);"><strong>DOC</strong> {0} / {1}</div>',
    'default': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(67, 93, 105); background: rgba(67, 93, 105, 0.75);"><strong>OOC {0}</strong> {1}</div>',
    'defaultAlt': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(255, 160, 122); background: rgba(255, 160, 122, 0.75);">{0}</div>',
    'print': '',
    'example:important': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(255, 160, 122); background: rgba(255, 160, 122, 0.75);">{0}</div>',
    'error': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(220, 20, 60); background: rgba(220, 20, 60, 0.75);"><strong>Chyba</strong>: {0}</div>',
    'warning': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(255, 140, 0); background: rgba(255, 140, 0, 0.75);"><strong>Varování</strong>: {0}</div>',
    'success': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(50, 205, 50); background: rgba(50, 205, 50, 0.75);"><strong>Úspěch</strong>: {0}</div>',
    'report': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(204, 51, 51); background: rgba(204, 51, 51, 0.75);"><strong>Report - {0}</strong>: {1}</div>',
    'respond': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(128, 0, 0); background: rgba(128, 0, 0, 0.75);"><strong>Odpověď hráči - {0}</strong>: {1}</div>',
    'player-msg': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(128, 0, 0); background: rgba(128, 0, 0, 0.75);"><strong>Zpráva od hráče - {0}</strong>: {1}</div>',
    'admin-msg': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(128, 0, 0); background: rgba(128, 0, 0, 0.75);"><strong>Zpráva od admina - {0}</strong>: {1}</div>',
    'to-admin-msg': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(128, 0, 0); background: rgba(128, 0, 0, 0.75);"><strong>Odpověď adminovi - {0}</strong>: {1}</div>',
    'tr': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(100, 149, 237); background: rgba(100, 149, 237, 0.75);"><strong>{0} přebral report od hráče {1}</strong></div>',
    'player-tr': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(100, 149, 237); background: rgba(100, 149, 237, 0.75);"><strong>{0} přebral Váš report</strong></div>',
    'report-done': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(36, 102, 235); background: rgba(36, 102, 235, 0.75);"><strong>{0} uzavřel report od hráče {1}</strong></div>',
    'ac': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(238, 103, 238); background: rgba(238, 103, 238, 0.75);"><strong>Admin Chat - {0}: </strong> {1}</div>',
    'police': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(0, 106, 209); background: rgba(0, 106, 209, 0.75);"><strong>{0}: </strong> {1}</div>',
    'medic': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(217, 44, 59); background: rgba(217, 44, 59, 0.75);"><strong>{0}: </strong> {1}</div>',
    'weazel': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(154, 50, 108); background: rgba(154, 50, 108);"><strong>{0}: </strong> {1}</div>',
    'announcement': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(244, 130, 131); background: rgba(244, 130, 131, 0.75);"><strong>OZNÁMENÍ ({0}): </strong> {1}</div>',
    'user-info': '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(244, 130, 131); background: rgba(244, 130, 131, 0.75);"><strong>{0}:</strong> {1}</div>',
    'dailyglobe' : '<div style="padding: 10px; margin: 5px; border-left: 10px solid rgb(34,139,34); background: rgba(34,139,34);"><strong>{0}: </strong> {1}</div>'
  },
  fadeTimeout: 5000,
  suggestionLimit: 5,
  style: {
    width: '30%',
  }
};
