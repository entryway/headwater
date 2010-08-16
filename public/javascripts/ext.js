jQuery.equals = function(x, y)
{
    for(p in y)
    {
        switch(typeof(y[p]))
        {
                case 'object':
                        if (!$.equals(x[p], y[p])) { return false }; break;
                case 'function':
                        if (typeof(x[p])=='undefined' || (p != 'equals' && y[p].toString() != x[p].toString())) { return false; }; break;
                default:
                        if (y[p] != x[p]) { return false; }
        }
    }

    for(p in x)
    {
        if(typeof(y[p])=='undefined') {return false;}
    }

    return true;
}

jQuery.index = function(item, array) {
  var index_of_item = -1;
  jQuery.each(array, function(index, array_item) {
    if ($.equals(item, array_item) == true) {
      index_of_item = index;
    };
  })
  return index_of_item;
}

jQuery.fn.startLoading = function() {
  $(this).children().hide();
  $("body").addClass('loading')
}

jQuery.fn.finishLoading = function() {
  $(this).children().show();
  $("body").removeClass('loading')
}