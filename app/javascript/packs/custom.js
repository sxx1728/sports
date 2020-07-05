function preview_image(input){
  var image_data = "";
  var file = input.files[0];
  if(!/image\/\w+/.test(file.type)){
    alert("请确保文件为图像类型");
    return false;
  }
  var reader = new FileReader();
  reader.onload = function (e) {
    $(input).parent().siblings('img').attr('src', e.target.result);
  }
  reader.readAsDataURL(file);
}

$(function() {
  $(".preview-image").change(function () {
    preview_image(this);
  });

  $("[data-behavior=select2]").select2();
  $("[data-behavior=daterangepicker]").daterangepicker({
    locale: { format: 'DD/MM/YYYY'},
    cancelLabel: 'Clear'
  });

});
