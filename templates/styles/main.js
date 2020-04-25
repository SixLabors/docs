$(function () {

    // The default header breaking function is breaking on camel casing which
    // screws up our longer namespace representations.
    // Update to add break after keyword only. 
    function breakPlainText(text) {
        if (!text) return text;
        return text.replace(/(Namespace|Class|Enum|Struct|Type|Interface)/g, '$1<wbr>');
    }

    console.log("Running New Breaker");
    $("h1.text-break").each(function () {
        let $this = $(this);

        $this.html(breakPlainText($this.text()));
    });
});