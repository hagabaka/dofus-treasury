$(document).ready(function() {
  $('.edit').editable('/inventory', {
    tooltip: 'click to edit',
    id: 'item',
    name: 'quantity',
    cssclass: 'inlineedit',
    submitdata: {ajax: 'yes'}
  });

  $('#itemname').autocomplete('/complete_item_name', {
    matchCase: 1
  });
});


