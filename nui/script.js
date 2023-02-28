$(function () {
    const open = (enable) => {
        document.body.style.display = enable ? "block" : "none";
    }

    const update = (list) => {
        if (list.length == null || (list.length == 0)) {
            $(".members-container").html(`
                <div class="member">
                    <h1 class="member-header">No members on this channel</h1>
                </div>
            `)
        }
        else {
            $(".members-container").empty()
            for (i = 0; i < list.length; i++) {
                $(".members-container").append(`
                    <div class="member">
                        <h1 class="member-header id="${i + 1}">${list[i]}</h1>
                    </div>
                `)
            }
        }
    }

    window.addEventListener("message", (event) => {
        const data = event.data;
        switch (data.type) {
            case "show":
                return open(data.enable);
            case "update":
                return update(data.list);
            default:
                return;
        }
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('https://cad-radio/escape', JSON.stringify({}));
        }
    };

    $("#channelsubmit").click(function () {
        $.post('https://cad-radio/joinRadio', JSON.stringify({
            channel: $("#channel").val()
        }));
    });

    $("#memberlist").click(function () {
        $('.channel').css('display', 'none');
        $('.members').css('display', 'block');
        $.post('https://cad-radio/getMembers', JSON.stringify({}));
    });

    $("#backchannel").click(function () {
        $('.members').css('display', 'none');
        $('.channel').css('display', 'block');
    });

    $(".power-onoff").click(function () {
        $.post('https://cad-radio/leaveRadio', JSON.stringify({}));
    });

    $(".volume-down").click(function () {
        $.post('https://cad-radio/volumeDown', JSON.stringify({}));
    });

    $(".volume-up").click(function () {
        $.post('https://cad-radio/volumeUp', JSON.stringify({}));
    });
});
