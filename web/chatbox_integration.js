function setIntercomSettings(data){
    window.intercomSettings = {
        app_id: "bnc5qtsi",
        name: data['userName'] + ' ' +data['userLastName'],
        email: data['email']
    };
}
function loadChatBox(){
    var w=window;
    var ic=w.Intercom;

    if(typeof ic==="function"){
        ic('reattach_activator');
        ic('update',w.intercomSettings);

    } else{
        var d=document;
        var i=function(){
            i.c(arguments);
        };

        i.q=[];
        i.c=function(args){
            i.q.push(args);
        };

        w.Intercom=i;
        var l=function(){

            var s=d.createElement('script');
            s.type='text/javascript';
            s.async=true;
            s.src='https://widget.intercom.io/widget/bnc5qtsi';
            var x=d.getElementsByTagName('script')[0];
            x.parentNode.insertBefore(s,x);
        };

        if(w.attachEvent){
            w.attachEvent('onload',l);
        } else{
            w.addEventListener('load',l,false);
        }
    }
}

//get user info from token
try {
    const dataString = localStorage.getItem('flutter.digitalAlignerData');
    //double parse (because of dart encode to localstorage)
    const data = JSON.parse(JSON.parse(dataString));
    
    setIntercomSettings(data);
    loadChatBox();
}catch(e){
    console.log(e);
}



