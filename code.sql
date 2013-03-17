CREATE OR REPLACE PACKAGE BODY TELEMED.tm_videoconference_v2 AS
  pkg_date       DATE;
  v_readonly     NUMBER (1);
  curr_image_src VARCHAR2 (100);
  d_doc number;


  PROCEDURE html (p_date IN VARCHAR2 := '') AS
    tmp_menu_num NUMBER (2);
    u_id         NUMBER;
  BEGIN
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;

    tm_common_v2.init;

    v_readonly   := 1;
    pkg_date     := TO_DATE (p_date, 'dd.mm.yyyy');
    
    d_doc := 1;

    IF NVL (pkg_date, qba_system.g_sysdate + 1) > qba_system.g_sysdate THEN
      pkg_date   := TRUNC (qba_system.g_sysdate);
    END IF;

    IF tm_common_v2.c#user_profile.role_id IN (2, 3, 4, 5) THEN
      u_id   := tm_common_v2.c#patient_id;
    ELSE
      u_id   := qba_system.g_user_id;
    END IF;

    --
    CASE
      WHEN tm_common_v2.c#user_profile.role_id IN (2, 3) THEN
        tmp_menu_num   := 2;
      WHEN tm_common_v2.c#user_profile.role_id IN (4, 5) THEN
        tmp_menu_num   := 5;
      WHEN tm_common_v2.c#user_profile.role_id = 6 THEN
        tmp_menu_num   := 2;
      ELSE
        tmp_menu_num   := 0;
    END CASE;


    tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.VIDEO_CONFERENCES')
                             ,p_sub_title => qba_lang.MESSAGE (p_name => 'SYS.VIDEO_CONFERENCES') /*   || qba_utils.ifnotnull (
                                                                                                          u_id
                                                                                                         ,   '</h5><h5 style="padding-top: 8px;">'
                                                                                                          || '<a href="#" title="" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'');return false;">'
                                                                                                          || '<input type="button" value="'
                                                                                                          || qba_lang.MESSAGE (p_name => 'SYS.CHOOSE_DATE')
                                                                                                          || '" class="seaBtn" /></a>')*/
                             ,p_left_menu_num => tmp_menu_num
                             ,prc_callback => 'tm_videoconference_v2.header_callback'
                             );

    HTP.p ('    <!-- Calendar -->');
    IF tm_common_v2.c#user_profile.role_id = 6 then
     HTP.p ('    <div id="div_diaryFullCalendar" style="display:none;">');
  end if;
  
  IF   tm_common_v2.c#user_profile.role_id <> 6 then
   HTP.p ('    <div id="div_diaryFullCalendar">');
 END IF;  
  --  HTP.p ('    <div id="div_diaryFullCalendar">');
    HTP.p ('      <div class="widget">');
    HTP.p ('        <div class="head"><h5 class="iDayCalendar">' || qba_lang.MESSAGE (p_name => 'SYS.EVENTS_CALENDAR') || '</h5></div>');
    HTP.p ('        <div id="diaryFullCalendar"></div>');
    HTP.p ('      </div>');
    HTP.p ('    </div>');

    CASE
      WHEN tm_common_v2.c#user_profile.role_id = 1 THEN
        print_doctor_conferences; --print_patient_videoconf;
      WHEN tm_common_v2.c#user_profile.role_id IN (2, 3) THEN
        print_doctor_conferences; --print_patient_videoconf;
      WHEN tm_common_v2.c#user_profile.role_id IN (4, 5) THEN
        print_doctor_conferences; --print_patient_videoconf;
      WHEN tm_common_v2.c#user_profile.role_id = 6 THEN
        print_patient_videoconf;
      ELSE
        NULL;
    END CASE;


    HTP.p ('<div class="widget">');
    HTP.p('<ul class="pane-list" id="panny">');
    
/*    IF TM_COMMON_V2.C#USER_PROFILE.role_id in(1,2,3,4,5) then
     HTP.p('     <li>');
    HTP.p('             <h3><a href ="#" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'')">Calendar</a></h3>');
    HTP.p('                      <p>Find your events</p>');
    HTP.p('     </li>'); 
     end if; */
    HTP.p('      <li>');
    HTP.p('              <h3><a href="#"  onclick="open_blank_window(''telemed_conf'',''1024'',''768'');$(''#conf_connect_form'').submit(); return false;">Connect to conference</a></h3>');
    HTP.p('               <p>Be online</p>');
    HTP.p('       </li>');
    HTP.p('</ul>');
 --   HTP.p('</div>');
    
    
   
    
   
    --OWA_UTIL.PRINT_CGI_ENV;
    HTP.p ('  <form name="myform" target="telemed_conf" id="conf_connect_form"  method="post" action="http://videomost.fors.ru/service/join/">');
    HTP.p ('    <input type="hidden" name="mac_go_app" value="0" />');
    HTP.p ('    <input type="hidden" name="confid" value="977004" />');
    HTP.p ('    <input type="hidden" name="confpass" value="12345" />');
    --IF tm_common_v2.c#user_profile.role_id IN (2, 3, 4, 5) THEN
    HTP.p ('    <input type="hidden" name="username" value="' || HTF.escape_sc (tm_get_user_name (qba_system.g_user_id)) || '" />'); --
    --else
    --HTP.p ('    <input type="hidden" name="username" value="' || HTF.escape_sc (tm_get_user_name (tm_common_v2.c#patient_id)) || '" />');
    --end if;
    HTP.p ('    <input type="hidden" name="remember" value="1" />');
   -- HTP.p ('    <br/>');
   /*
    ---this is working part
    HTP.p ('<a href="#" title="" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'');return false;">                                                 
        <input type="button" value="20.08.2012" class="seaBtn"></a>');
   /    
         HTP.p (
         '    <a href="#" target="_blank" title="">'
      || '<input value="Connect to conference" class="redBtn" type="button" onclick="open_blank_window(''telemed_conf'',''1024'',''768'');$(''#conf_connect_form'').submit(); return false;"/>'
      || '</a>'
    );  
    ---end of
    */
    HTP.p ('  </form>');
    HTP.p ('</div>');
    
    HTP.p('</div>');

    tm_common_v2.page_footer;
  END html;

  PROCEDURE print_patient_videoconf AS
  BEGIN
    HTP.p ('');
    HTP.p ('    <!-- patient dashboard -->');
    print_user_conferences;
  END print_patient_videoconf;

  PROCEDURE print_user_conferences AS
  BEGIN
    IF tm_common_v2.c#user_profile.role_id IN (1) AND tm_common_v2.c#patient_id IS NULL THEN
      RETURN;
    END IF;

    HTP.p ('    <div class="widget">');
    HTP.p ('      <ul class="tabs">');
    HTP.p (
         '        <li class="" style=""><a href="#tab1">'
      || OWA_UTIL.ite (tm_common_v2.c#patient_id IS NULL, qba_lang.MESSAGE (p_name => 'SYS.LIVE_CONFERENCE'), qba_lang.MESSAGE (p_name => 'SYS.LIVE_CONFERENCE'))
      || '</a></li>'
    );

      HTP.p (
         '        <li class = " "><a href="#tab2">'
      || OWA_UTIL.ite (tm_common_v2.c#patient_id IS NULL, qba_lang.MESSAGE (p_name => 'SYS.DOCTOR_LIST'), qba_lang.MESSAGE (p_name => 'SYS.DOCTOR_LIST'))
      || '</a></li>'
    );
    HTP.p ('      </ul>');


    HTP.p ('      <div class="tab_container">');

    HTP.p ('        <div id="tab1" class="tab_content">');
--    tm_prescription_v2.print_user_live_confs;
    print_current_conference;
    HTP.p ('        </div>');


    HTP.p ('        <div id="tab2" class="tab_content" style="display: block; ">');
    prn_doc_list (tm_common_v2.c#user_profile.user_id);
    HTP.p ('        </div>');
    HTP.p ('      </div>');

  END print_user_conferences;
  
  PROCEDURE print_current_conference AS
  BEGIN
     IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
     HTP.p ('            <table id="tbl_list_docs_user" cellpadding="0" cellspacing="0" width="100%" class="tableStatic" >');
      HTP.p ('              <thead>');
      HTP.p ('                <tr>');
      HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.TIME') || '</td>');
 --     HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.END_TIME') || '</td>');
      HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.SPECIALIST') || '</td>');
      HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.STATUS') || ' </td>');
      HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.CONNECT') || ' </td>');
      HTP.p ('                </tr>');
      HTP.p ('              </thead>');
      
      HTP.p ('              <tbody>');
        
        FOR rec in( 
            select TO_CHAR (trunc_ts_tz (tdf.date_from, 'MI', 'CURRENT'), 'dd.mm.yyyy', 'NLS_DATE_LANGUAGE = AMERICAN') as tyear,
                        TO_CHAR (trunc_ts_tz (tdf.date_from, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN') as tstart,
                        TO_CHAR (trunc_ts_tz (tdf.date_to, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN') as tend,
                        
                         TDF.ACCEPTED as status,
                         QA.FIRST_NAME as namer,
                         QA.LAST_NAME as surname,
                         TDF.DATE_FROM as valid,
                         TDF.DATE_TO as valid2
            from tm_doc_free_time tdf, qba_users qa where TDF.PATIENT = QBA_SYSTEM.G_USER_ID and QA.USER_ID = TDF.DOC_ID
            order by TDF.DATE_FROM DESC ) loop
           HTP.p ('                <tr>');
           HTP.p ('                  <td>' || rec.tyear ||'  ' || qba_lang.MESSAGE (p_name => 'SYS.FROM') ||' '||rec.tstart||' ' || qba_lang.MESSAGE (p_name => 'SYS.TO') || ' ' ||rec.tend||  '</td>');
      --     HTP.p ('                  <td>' || rec.end_time|| '</td>');
           HTP.p ('                  <td>' ||rec.surname ||' '||  rec.namer|| '</td>');
           if rec.valid >= sysdate then
                     IF rec.status = 1 then
                             HTP.p ('                  <td>'|| qba_lang.MESSAGE (p_name => 'SYS.Pending')||'</td>');
                    end if;
                    IF rec.status = 2 then
                            HTP.p ('                  <td>'|| qba_lang.MESSAGE (p_name => 'SYS.ACCEPTED') ||'</td>'); 
                    end if;
              else 
                           HTP.p ('                  <td>'|| qba_lang.MESSAGE (p_name => 'SYS.FINISHED') ||'</td>'); 
                  end if;
                  
                  if rec.valid <= sysdate and rec.valid2 >= sysdate then
                            HTP.p ('                  <td>ok</td>');
                  else
                            HTP.p ('                  <td><img src="' || tm_common.c#images || 'files.png" border="0" alt="" /></td>');
                  end if;      
           
           HTP.p ('                </tr>');
         END LOOP;
            
            
            
        
        HTP.p ('              </tbody>');
      
      
       HTP.p ('            </table>');
    
    
    
    
  END print_current_conference;
  

  PROCEDURE print_doctor_conferences AS
  BEGIN
    IF tm_common_v2.c#user_profile.role_id IN (1) AND tm_common_v2.c#patient_id IS NULL THEN
      RETURN;
    END IF;


  -- HTP.p ('    <div class="widget">');

  /*  HTP.p ('<a href="#" title="" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'');return false;">
        <input type="button" value="20.08.2012" class="seaBtn"></a>');
        
         HTP.p (
         '    <a href="#" target="_blank" title="">'
      || '<input value="Connect to conference" class="redBtn" type="button" onclick="open_blank_window(''telemed_conf'',''1024'',''768'');$(''#conf_connect_form'').submit(); return false;"/>'
      || '</a>'
    );  */
    
    /*
    HTP.p('<ul class="pane-list">');
    HTP.p('     <li>');
    HTP.p('             <h3><a href ="#" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'')">Calendar</a></h3>');
    HTP.p('                      <p>Here you can find your events</p>');
    HTP.p('     </li>');
    HTP.p('      <li>');
    HTP.p('              <h3><a href="#"  onclick="open_blank_window(''telemed_conf'',''1024'',''768'');$(''#conf_connect_form'').submit(); return false;">Connect to conference</a></h3>');
    HTP.p('               <p>Be online with your doctor</p>');
    HTP.p('       </li>');
    HTP.p('</ul>');
    */


 -- HTP.p ('</div>');
  END print_doctor_conferences;


  PROCEDURE header_callback (event_type IN VARCHAR2 := '',doctor in number:=41) AS
  docer   number;
  BEGIN
    CASE header_callback.event_type
      WHEN 'add_to_head' THEN
        -- IF (tm_common_v2.c#user_profile.role_id IN (2, 3, 4, 5, 6) AND tm_common_v2.c#patient_id IS NOT NULL) OR tm_common_v2.c#user_profile.role_id = 6 THEN
        HTP.p ('<script type="text/javascript">');
        
        --opening videoconferentions in new window
        HTP.p ('var selected;');
        HTP.p ('  function open_window(link,w,h) //opens new window
                    {
                        var win = "width="+w+",height="+h+",menubar=no,location=no,resizable=yes,scrollbars=yes";
                    //   $(''#conf_connect_form'').submit();
                         selected = window.open(link,"selected",win);
                    //   newWin = window.open('',"mywin","width=300,height=200");
                   //     selected = newWin;
                           selected.focus();
                       };');

        HTP.p ('function open_blank_window(wname,w,h) {');
        HTP.p ('  var win_wh = "width="+w+",height="+h+",menubar=no,location=no,resizable=yes,scrollbars=yes";');
        HTP.p ('  var wndh = window.open("",wname,win_wh);');
        HTP.p ('  wndh.document.write("<"+"p>' || qba_lang.MESSAGE (p_name => 'SYS.LOADING') || '"+"<"+"/p>");');
        HTP.p ('  wndh.focus();');
        HTP.p ('}');


        HTP.p ('function closeWindow() { window.opener=''x'';window.close();}');


        HTP.p ('$(document).ready(function(){');
        
        --searching by current conferences
        HTP.p ('  $(''table[id^="tbl_list_"]'').dataTable({');
        HTP.p ('    "bJQueryUI": true,');
        HTP.p ('    "bAutoWidth": false,');
        HTP.p ('    "bSort": false,');
        HTP.p ('    "oLanguage": {"sUrl": "' || tm_common_v2.c#js || 'jquery.' || tm_common_v2.jquery_version || '/dataTables/jquery.dataTables.' || qba_system.g_browser_language || '.js"},');
        HTP.p ('    "sPaginationType": "full_numbers",');
        HTP.p ('    "sDom": '' < "" f>t<"F"lp>'',');
        HTP.p ('    "aoColumnDefs": [');
        HTP.p ('      { "bSortable": false, "aTargets": [ "_all" ] }');
        HTP.p ('    ],');
        HTP.p ('    "fnInitComplete": function(oSettings, json){');
        HTP.p ('      $(''table[id^="tbl_list_"]'').parent().find(''.dataTables_filter input'').attr("placeholder", "' || qba_lang.MESSAGE (p_name => 'SYS.PLACEHOLDER_SEARCH') || '");');
        HTP.p ('    }');
        HTP.p ('  });');
        
        
        
       HTP.p('$(".pane-list li").click(function(){
                             window.location=$(this).find("a").attr("href");return false;
                     });
        ');


        IF tm_common_v2.c#user_profile.role_id = 6 THEN  
        
         HTP.p ('  fullCalendarOptions["dayClick"] = function(dt) {');
   --       HTP.p ('    window.location.href="' || tm_common_v2.c#base_path || '" + dt.getFullYear() + "/" + (dt.getMonth()+1) + "/" + dt.getDate() + "/' || c#package || '.new_date";');
          HTP.p ('  };');
          HTP.p('   fullCalendarOptions["eventClick"] = function(et) {');
          HTP.p('     window.location.href="' || tm_common_v2.c#base_path || '" + dt.getFullYear() + "/" + (dt.getMonth()+1) + "/" + dt.getDate() + "/' || c#package || '.new_date?doctor='||d_doc||'";'); 
          HTP.p('};');
          
          HTP.p ('         fullCalendarOptions["events"] = "' || tm_common_v2.c#base_path || 'dyn/' || c#package ||'.get_dates_list?docer='||d_doc||'";');  
         HTP.p('var doc_calendar = "";');   
         HTP.p ('  $("#diaryFullCalendar").fullCalendar(fullCalendarOptions);');
        
        
     /*   
        HTP.p('$(''.pushOnMe'').click(function() {');
       
        HTP.p('    doc_calendar = $(this).attr("id");');
       
     --  HTP.p ('  fullCalendarOptions["events"] = "' || tm_common_v2.c#base_path || 'dyn/' || c#package ||'.get_dates_list?doc_id=''doc_calendar";');  
       
       HTP.p ('         fullCalendarOptions["events"] = "' || tm_common_v2.c#base_path || 'dyn/' || c#package ||'.get_dates_list?docer=123";');  
       
   --    HTP.p(' $(''#div_diaryFullCalendar'').toggle();  $(''#diaryFullCalendar'').fullCalendar(''refresh'')');
        
        HTP.p(' $(''#div_diaryFullCalendar'').toggle();  $(''#diaryFullCalendar'').fullCalendar(''render'')');
    
    --   HTP.p('     $("#diaryFullCalendar").fullCalendar("refetchEvents");');
       
      --  HTP.p('     alert(doc_calendar.toString())');
        HTP.p('});');
   */
   
   
   
   END IF; --

        
        
        
      
        IF tm_common_v2.c#user_profile.role_id in (1,2,3,4,5) THEN     
      /*    HTP.p('  $("#pushOK").click( function() {');
          HTP.p('       var select1 =  $("#u_left  option:selected").text(); ' );
          HTP.p('       var select2 =  $("#u_right  option:selected").text(); ' );
          HTP.p('       var select3 = $("#labeler").text();');
          HTP.p('     $.ajax( {');
          HTP.p('          type: "POST",');
          HTP.p('          url: "'||tm_common_v2.c#base_path || c#package ||'.doc_add_time", ');                                                                       --WORKING HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          HTP.p('          data : { date_f: select1, date_t: select2, ymd: select3 },');
          HTP.p('          cache: false, ');
          HTP.p ('          success: function(html){');
          HTP.p ('            $.cookie("light_message", html, { domain: "' || qba_system.g_user_server_name || '", path: "' || tm_common_v2.c#base_path || '" });');
          HTP.p ('            window.location.reload();');
          HTP.p ('          }');
          HTP.p (    '});' );
          HTP.p(' }); ');
        
          HTP.p('  $("#pushACCEPT").click( function() {');
      
          HTP.p('       var deleteYear = $(''#deleteYear'').text();');
          HTP.p('       var  vfrom         = $("#val1").val(); ');
          HTP.p('       var vto               = $("#val2").val();');
          HTP.p('       var fullDate = deleteYear  + vfrom ;');
         HTP.p('     $.ajax( {');
          HTP.p('          type: "POST",');
          HTP.p('          url: "'||tm_common_v2.c#base_path || c#package ||'.change_status", ');                                                                       --WORKING HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          HTP.p('          data : { ch_time: fullDate },');
          HTP.p('          cache: false, ');
          HTP.p ('          success: function(html){');
          HTP.p ('            $.cookie("light_message", html, { domain: "' || qba_system.g_user_server_name || '", path: "' || tm_common_v2.c#base_path || '" });');
          HTP.p ('            window.location.reload();');
          HTP.p ('          }') ;
          HTP.p (    '});' );
          HTP.p(' }); ');
          
          
           HTP.p('  $("#pushDEL").click( function() {');
          HTP.p('       var deleteYear = $(''#deleteYear'').text();');
          HTP.p('       var  vfrom         = $("#val1").val(); ');
          HTP.p('       var vto               = $("#val2").val();');
          HTP.p('       var fullDate = deleteYear  + vfrom ;');
         HTP.p('     $.ajax( {');
          HTP.p('          type: "POST",');
          HTP.p('          url: "'||tm_common_v2.c#base_path || c#package ||'.delete_event", ');                                                                       --WORKING HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          HTP.p('          data : { ch_time: fullDate },');
          HTP.p('          cache: false, ');
          HTP.p ('          success: function(html){');
          HTP.p ('            $.cookie("light_message", html, { domain: "' || qba_system.g_user_server_name || '", path: "' || tm_common_v2.c#base_path || '" });');
          HTP.p ('            window.location.reload();');
          HTP.p ('          }') ;
          HTP.p (    '});' );
          HTP.p(' }); ');
         */ 
          
          HTP.p ('  fullCalendarOptions["events"] = "' || tm_common_v2.c#base_path || 'dyn/' || c#package || '.doc_get_dates_list";');
          
           HTP.p ('  fullCalendarOptions["dayClick"] = function(dt) {');
           
       -- 
              --HTP.p('   var clickday = $("#diaryFullCalendar").fullCalendar("getDate"); ');
              
              HTP.p('   var clickday = "clickday"; ');
                     
              HTP.p ('    window.location.href="' || tm_common_v2.c#base_path || '" + dt.getFullYear() + "/" + (dt.getMonth()+1) + "/" + dt.getDate() + "/' || c#package || '.doc_new_date";');
      --     HTP.p('   }');
           HTP.p('  };  ');
          
          HTP.p('   fullCalendarOptions["eventClick"] = function(et) {');
          HTP.p('     window.location.href="' || tm_common_v2.c#base_path || '" + dt.getFullYear() + "/" + (dt.getMonth()+1) + "/" + dt.getDate() + "/' || c#package || '.doc_change_event";'); 
          HTP.p(' };');
         
        HTP.p ('  $("#diaryFullCalendar").fullCalendar(fullCalendarOptions);');
         
        END IF;

        HTP.p ('});');
        HTP.p ('</script>');
      ELSE
        NULL;
    END CASE;
  END header_callback;
  
  PROCEDURE header_callback2 (event_type IN VARCHAR2 := '',doc_id number)
  as
  begin
  
  CASE header_callback2.event_type
      WHEN 'add_to_head' THEN
        -- IF (tm_common_v2.c#user_profile.role_id IN (2, 3, 4, 5, 6) AND tm_common_v2.c#patient_id IS NOT NULL) OR tm_common_v2.c#user_profile.role_id = 6 THEN
        HTP.p ('<script type="text/javascript">');
          HTP.p ('  fullCalendarOptions["dayClick"] = function(dt) {');
          HTP.p ('  };');
          HTP.p('   fullCalendarOptions["eventClick"] = function(et) {');
          HTP.p('     window.location.href="' || tm_common_v2.c#base_path || '" + dt.getFullYear() + "/" + (dt.getMonth()+1) + "/" + dt.getDate() + "/' || c#package || '.new_date";'); 
          HTP.p('};');
        
         
          HTP.p ('         fullCalendarOptions["events"] = "' || tm_common_v2.c#base_path || 'dyn/' || c#package ||'.get_dates_list?docer='||doc_id||'";');  
        
        else null;
        end case;
  
  end header_callback2;
  
  PROCEDURE change_status(ch_time varchar2:='') as
  rec_id number;
  
  mpatient number;
  
  date_from varchar2(20);
  time_from varchar2(20);
  time_to     varchar2(20);
  
  answer varchar(200);
  
  begin
  
   IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
   
    select TDF.ID into rec_id  from tm_doc_free_time tdf where TO_CHAR(TDF.DATE_FROM,'dd.mm.yyyyhh24:mi' ) = ch_time and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID;
    
    select TDF.PATIENT into mpatient  from tm_doc_free_time tdf where TO_CHAR(TDF.DATE_FROM,'dd.mm.yyyyhh24:mi' ) = ch_time and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID;
    
    select TO_CHAR(TDF.DATE_FROM,'dd.mm.yyyy' ) into date_from  from tm_doc_free_time tdf where TDF.ID = rec_id;
    select TO_CHAR(TDF.DATE_FROM,'hh24:mi' ) into time_from  from tm_doc_free_time tdf where TDF.ID = rec_id;
    select TO_CHAR(TDF.DATE_TO,'hh24:mi' ) into time_to  from tm_doc_free_time tdf where TDF.ID = rec_id;
    
    answer := date_from||'  '|| qba_lang.MESSAGE (p_name => 'SYS.FROM') ||' '|| time_from ||' '|| qba_lang.MESSAGE (p_name => 'SYS.TO') ||' '||time_to||' '||  qba_lang.MESSAGE (p_name => 'SYS.PACCEPT');
    
    update tm_doc_free_time set TM_DOC_FREE_TIME.ACCEPTED = 2 where TM_DOC_FREE_TIME.ID = rec_id and TM_DOC_FREE_TIME.ACCEPTED = 1;
    
    
    
    TM_MESSAGES_V2.SEND_MESSAGE(QBA_SYSTEM.G_USER_ID,mpatient,answer,0);
    
    qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
    
       qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.ALL_CHANGES_SAVED'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
    sys.OWA_UTIL.http_header_close;
    
  
  end change_status;
  
  
  PROCEDURE delete_event(ch_time varchar2:='') as
  rec_id number;
  begin
  
   IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
   
    select TDF.ID into rec_id  from tm_doc_free_time tdf where TO_CHAR(TDF.DATE_FROM,'dd.mm.yyyyhh:mi' ) = ch_time and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID;
    DELETE FROM tm_doc_free_time WHERE TM_DOC_FREE_TIME.ID = rec_id ;
    
  end delete_event;
  
  

  PROCEDURE prn_doc_list (p_user_id IN NUMBER := qba_system.g_user_id) AS
  BEGIN
    --
    HTP.p ('          <table cellpadding="0" cellspacing="0" width="100%" class="tableStatic" style="border: 1px solid #d5d5d5;">');
    HTP.p ('            <thead>');
    HTP.p ('              <tr >');
    HTP.p ('                <td style="width:100px;">' || qba_lang.MESSAGE (p_name => 'SYS.NAME') || '</td>');
    HTP.p ('                <td style="width:130px;">' || qba_lang.MESSAGE (p_name => 'SYS.STATUS') || '</td>');
    HTP.p ('                <td>' || qba_lang.MESSAGE (p_name => 'SYS.SPECIALTY') || '</td>');
 --   HTP.p ('                <td style="width:80px;">' || qba_lang.MESSAGE (p_name => 'SYS.CONTACT_INFO') || '</td>');
    HTP.p ('                <td style="width:80px;">' || qba_lang.MESSAGE (p_name => 'SYS.PROFILE') || '</td>');
    HTP.p ('              </tr>');
    HTP.p ('            </thead>');
    HTP.p ('            <tbody>');

    FOR rec IN (SELECT vv.*
                  FROM v_agn_doctor_list vv
                 WHERE vv.agn_id = p_user_id
                UNION ALL
                SELECT vv.*
                  FROM v_pat_doctor_list vv
                 WHERE vv.pat_id = p_user_id
                ORDER BY 4, 5, 6) LOOP
      HTP.p ('              <tr>');
  --    HTP.p ('                <td><a href="#" title="" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'');return false;" id ="opop" class="pushOnMe">' || rec.LAST_NAME|| '</a></td>');
    --   HTP.p ('                <td><a href="#" id ="'||rec.user_id||'" class="pushOnMe">' || rec.LAST_NAME|| '</a></td>');
      HTP.p ('                <td>' || rec.LAST_NAME|| '</td>');
      HTP.p ('                <td>' || tm_get_role_name (rec.role_id)|| '</td>');
      HTP.p ('                <td>' || tm_get_user_spec_list (rec.user_id)|| '</td>');
 --     HTP.p ('                <td>' || rec.email_address|| '</td>');
      HTP.p ('<td>');
       IF rec.avatar_file_name IS NOT NULL THEN
    --     HTP.p ('         <a href="#" id ="'||rec.user_id||'" class="pushOnMe"> <img src="' || tm_common_v2.c#attach_doc_href || rec.avatar_file_name || '" border="0" align="right" alt="" style="height:90px;width:90px;" /></a>');
          
       HTP.p ('         <a href="'||tm_common_v2.c#base_path||''||c#package ||'.print_choose_calendar?doc_num='||rec.user_id||'" id ="'||rec.user_id||'" class="pushOnMe"> <img src="' || tm_common_v2.c#attach_doc_href || rec.avatar_file_name || '" border="0" align="right" alt="" style="height:90px;width:90px;" /></a>');
     /*  d_doc :=  rec.user_id; 
     
       HTP.p( '<a href="#" title="" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'');return false;"><img src="' || tm_common_v2.c#attach_doc_href || rec.avatar_file_name || '" border="0" align="right" alt="" style="height:90px;width:90px;" /></a>');*/
       
        ELSE
          HTP.p ('         <a href="'||tm_common_v2.c#base_path||''||c#package ||'.print_choose_calendar?doc_num='||rec.user_id||'" id="'||rec.user_id||'" class="pushOnMe"> <img src="' || tm_common_v2.c#images || 'noavator_' || OWA_UTIL.ite (rec.sex = 1, 'm', 'w') || '.png" border="0" align="right" alt="" /></a>');
          
        END IF;
      HTP.p('</td>');
      HTP.p ('              </tr>');
    END LOOP;

    HTP.p ('            </tbody>');
    HTP.p ('          </table>');
  END prn_doc_list;



  PROCEDURE get_dates_list (name_array IN OWA.vc_arr, value_array IN OWA.vc_arr) AS
    u_id      NUMBER;
    dt_start  DATE;
    dt_end    DATE;
    jsonarray json_list;
    jsonobj   json;
    doctor number;
    end_time varchar(20);
    dend date;
  BEGIN
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;

  tm_common_v2.init;

    IF tm_common_v2.c#user_profile.role_id <> 6 AND tm_common_v2.c#patient_id IS NOT NULL THEN
      u_id   := tm_common_v2.c#patient_id;
    ELSE
      u_id   := qba_system.g_user_id;
    END IF;

    IF u_id IS NULL THEN
      RETURN;
    END IF;

    dt_start    := date_linux2oracle (TO_NUMBER (qba_utils.get_val_from_arr (name_array, value_array, 'start')));
    dt_end      := date_linux2oracle (TO_NUMBER (qba_utils.get_val_from_arr (name_array, value_array, 'end')));
    doctor      :=   qba_utils.get_val_from_arr (name_array, value_array, 'docer');

    jsonarray   := json_list ();
    
    
 IF tm_common_v2.c#user_profile.role_id = 6 THEN     
    FOR rec
      IN (SELECT TO_CHAR (trunc_ts_tz (dc.date_from, 'MI', 'CURRENT'), 'Dy, dd Mon yyyy hh24:mi:ss', 'NLS_DATE_LANGUAGE = AMERICAN') AS dt1
          --      ,TO_CHAR (dc.date_to, 'hh24:mi') AS dt2
                 ,TO_CHAR (trunc_ts_tz (dc.date_to, 'MI', 'CURRENT'), 'Dy, dd Mon yyyy  hh24:mi:ss', 'NLS_DATE_LANGUAGE = AMERICAN') AS dt2
                 ,TO_CHAR (trunc_ts_tz (dc.date_from, 'MI', 'CURRENT'), 'yyyy/mm/dd', 'NLS_DATE_LANGUAGE = AMERICAN') AS dt3
          --      ,TO_CHAR (dc.date_from, 'yyyy/mm/dd') AS dt3
                ,dc.doc_id AS doctor
                ,DC.ACCEPTED as ACCEPTED
                ,DC.PATIENT as PATIENT
                ,to_char(DC.DATE_FROM,'HH24:MI') as event_time
                ,DC.DATE_FROM as valid
         FROM tm_doc_free_time dc, qba_users qa where DC.DOC_ID = doctor and QA.USER_ID = doc_id and  DC.PATIENT IS NULL
        
       union
         
         SELECT TO_CHAR (trunc_ts_tz (dc.date_from, 'MI', 'CURRENT'), 'Dy, dd Mon yyyy hh24:mi:ss', 'NLS_DATE_LANGUAGE = AMERICAN') AS dt1
          --      ,TO_CHAR (dc.date_to, 'hh24:mi') AS dt2
                 ,TO_CHAR (trunc_ts_tz (dc.date_to, 'MI', 'CURRENT'), 'Dy, dd Mon yyyy  hh24:mi:ss', 'NLS_DATE_LANGUAGE = AMERICAN') AS dt2
                 ,TO_CHAR (trunc_ts_tz (dc.date_from, 'MI', 'CURRENT'), 'yyyy/mm/dd', 'NLS_DATE_LANGUAGE = AMERICAN') AS dt3
          --      ,TO_CHAR (dc.date_from, 'yyyy/mm/dd') AS dt3
                ,dc.doc_id AS doctor
                ,DC.ACCEPTED as ACCEPTED
                ,DC.PATIENT as PATIENT
                ,to_char(DC.DATE_FROM,'HH24:MI') as event_time
                ,DC.DATE_FROM as valid
         FROM tm_doc_free_time dc, qba_users qa where DC.DOC_ID = doctor and QA.USER_ID = doc_id and  DC.PATIENT = QBA_SYSTEM.G_USER_ID)
         
         
          LOOP
           jsonobj   := json ();
      
         dend := TO_DATE(rec.dt2,'Dy, dd Mon yyyy hh24:mi:ss');
         end_time := TO_CHAR(dend,'hh24:mi');
      
          IF rec.valid >= sysdate then
              
          -- jsonobj.put ('title', '- '||rec.dt2||'');
       --     jsonobj.put ('title', '- '||end_time||'');
           jsonobj.put ('title', ' - '||end_time|| '  '|| qba_lang.MESSAGE (p_name => 'SYS.FREE')||'');
           jsonobj.put ('start', rec.dt1);
           jsonobj.put ('end', rec.dt2);
            jsonobj.put ('allDay', FALSE);
            IF rec.accepted = 0 then
                    jsonobj.put ('color', '#4682B4');    
                    jsonobj.put ('url', tm_common_v2.c#base_path || rec.dt3 || '/' || c#package || '.new_date?event_time='||rec.event_time||'');
            end if;        
            if rec.accepted = 1 then
                    jsonobj.put ('color', '#B55D5C');
                  --  jsonobj.put ('title', 'pending');
                   jsonobj.put ('title', ' - '||end_time|| '  '|| qba_lang.MESSAGE (p_name => 'SYS.PENDING')||'');
             end if;
            if rec.accepted = 2 then
                --    jsonobj.put ('title', '- '||end_time||'');
                       jsonobj.put ('title', ' - '||end_time|| '  '|| qba_lang.MESSAGE (p_name => 'SYS.ACCEPTED')||'');
                  --  jsonobj.put ('title', '- '||rec.dt2||'');
                   jsonobj.put ('color', '#228B22');
            end if;
       
        end if;
      
       
          if rec.valid < sysdate and rec.accepted = 2 then
                jsonobj.put ('start', rec.dt1);
                jsonobj.put ('end', rec.dt2);
                jsonobj.put ('title',   qba_lang.MESSAGE (p_name => 'SYS.FINISHED'));
                jsonobj.put ('color', '#483D8B');
                jsonobj.put ('allDay', TRUE);  
         end if; 
        
     
    
    
         jsonarray.append (jsonobj.to_json_value);
      
      
       
      
    
    END LOOP;
    
    END IF;
    
   
  
  jsonarray.HTP;
  END get_dates_list;
  
  
  /* Formatted on 30.08.2012 13:02:12 (QP5 v5.185.11230.41888) */
PROCEDURE doc_change_event (name_array IN OWA.vc_arr, value_array IN OWA.vc_arr)  AS

     rec_users   QBA_USERS%ROWTYPE;
     upd_user_id  QBA_USERS.USER_ID%TYPE;
     upd_date_start  TM_DOC_FREE_TIME.DATE_FROM%TYPE;
     upd_date_end   TM_DOC_FREE_TIME.DATE_TO%TYPE;
     ref_proc varchar(200);
     
     nn number;
  

BEGIN
      
  
      IF qba_system.qba_engine_stopped  THEN
            RETURN;
       END IF;

    tm_common_v2.init;

    upd_user_id    := qba_utils.get_val_from_arr (name_array, value_array, 'uid');
    ref_proc       := qba_utils.get_val_from_arr (name_array, value_array, 'ref_proc', tm_common_v2.c#base_path || c#package || '.html');
    
     IF name_array.COUNT > 0 THEN
      FOR nn IN name_array.FIRST .. name_array.LAST LOOP
        CASE name_array (nn)
          WHEN 'u_subscriber_id_left' THEN
            upd_date_start   := TRIM (value_array (nn));
          WHEN 'u_subscriber_id_right' THEN
            upd_date_end   := TRIM (value_array (nn));
            
          ELSE
            NULL;
        END CASE;
      END LOOP;
     
      COMMIT;
    END IF;

 END doc_change_event;
  
  PROCEDURE doc_new_date(p_date IN VARCHAR2 := '', doc_id IN NUMBER := qba_system.g_user_id,time_id in NUMBER := 0, prid in number := 0) AS
  my_date DATE;
  endest varchar(20) := '';
  time_part TM_DOC_FREE_TIME%ROWTYPE;
  
  fulltime varchar(20);
  
  dater varchar2(20);
  BEGIN
    
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    tm_common_v2.init;
  
    tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.SELECT_TIME'), p_left_menu_num => 0, prc_callback =>'tm_videoconference_v2.header_callback');
    
    pkg_date   := TO_DATE (p_date, 'dd.mm.yyyy');    
    
    dater := TO_CHAR(pkg_date,'yyyy.mm.dd');
    
   --  select TO_CHAR(TDF.DATE_FROM,'hh24:mi') into fulltime from tm_doc_free_time  tdf  where TO_CHAR(TDF.DATE_FROM,'yyyy.mm.dd') = dater;   
    
    
    HTP.p('<div class="widget ">');
   
   HTP.p ('      <form id="frm_doc_new" action="' || tm_common_v2.c#base_path|| 'dyn/' ||c#package ||'.upd_calendar" method="post" class="mainForm">');
    HTP.p ('        <fieldset>');  
    
  --  if fulltime is null then
    print_times('00:00','23:30',dater);
 --  end if;
    HTP.p (  '<div class="rowElem noborder " align="left"><a href="#" onclick="$(''#frm_doc_new'').submit();return false;" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.SAVE')|| '" class="seaBtn" /></a>' );
    HTP.p (  '<a href=" '||tm_common_v2.c#base_path|| c#package || '.html" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.CANCEL')|| '" class="seaBtn" /></a></div></br>' );
    
  
    

    HTP.p('          </fieldset>');
    HTP.p('</form>');
   
   HTP.p ('                <div class="fix"></div>');
   HTP.p('</div>');
    
    tm_common_v2.page_footer;
   
  END doc_new_date;


  PROCEDURE new_date (p_date IN VARCHAR2 := '', doctor IN NUMBER ,event_time varchar2 := '') AS
    my_date DATE;
    endest varchar(20) := '';
    minut number(30);
    times          tm_doc_free_time%ROWTYPE;
    dater varchar2(20);
    p_time tm_time_stamps%ROWTYPE;
    num_doctor number;
    
    new_p_date varchar(20);
    
    maxer  varchar2(20);
    miner varchar2(20);
    
    date_for_ref varchar(20);
    
  
  BEGIN
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;

    tm_common_v2.init;
    tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.SELECT_TIME'), p_left_menu_num => 0, prc_callback => 'tm_messages_v2.header_callback_new_msg');
    
     
    
    pkg_date   := TO_DATE (p_date, 'dd.mm.yyyy');
    dater := TO_CHAR(pkg_date,'yyyy.mm.dd');
    date_for_ref := TO_CHAR(pkg_date,'yyyy/mm/dd');
    
    new_p_date := TO_CHAR(pkg_date,'dd.mm.yyyy');
   /*   FOR rec IN (SELECT TO_CHAR (trunc_ts_tz (tdf.date_from, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN') AS t_start, TO_CHAR (trunc_ts_tz (tdf.date_to, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN')  AS t_end
           FROM tm_doc_free_time tdf
           WHERE TO_CHAR (tdf.date_from, 'dd.mm.yyyy') = TO_CHAR (pkg_date, 'dd.mm.yyyy') AND TO_CHAR(TDF.DATE_FROM,'hh24:mi') = event_time ) LOOP */
           
           
        FOR rec IN (SELECT TO_CHAR (trunc_ts_tz (tdf.date_from, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN') AS t_start, TO_CHAR(tdf.date_from,'hh24:mi') as n_start, TO_CHAR(tdf.date_to,'hh24:mi') as n_end, 
        TO_CHAR (trunc_ts_tz (tdf.date_to, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN')  AS t_end
           FROM tm_doc_free_time tdf
   --        WHERE TO_CHAR (tdf.date_from, 'dd.mm.yyyy') = TO_CHAR (pkg_date, 'dd.mm.yyyy') AND TO_CHAR(TDF.DATE_FROM,'hh24:mi') = event_time ) LOOP
          WHERE  TO_CHAR (trunc_ts_tz (tdf.date_from, 'MI', 'CURRENT'), 'dd.mm.yyyy', 'NLS_DATE_LANGUAGE = AMERICAN')  = TO_CHAR (pkg_date, 'dd.mm.yyyy') AND TO_CHAR(TDF.DATE_FROM,'hh24:mi') = event_time ) LOOP  
   --   num_doctor := d_doc;
   
    select TVS.LAS_VISIT into num_doctor  from tm_video_session tvs where TVS.SESSION_ID = 1;
  
   HTP.p('<div class="widget ">');    --1
    HTP.p ('      <form id="frm_new" action="' || tm_common_v2.c#base_path|| 'dyn/' ||c#package ||'.choose_interval?doc_id='||num_doctor||'" method="post" class="mainForm">');           
    HTP.p ('        <fieldset>');  
    
 -- HTP.p(' <input type=text readonly id="u_label" name="u_label" value="'||num_doctor||'" style="width:60px; margin-left:19px"/>');
   HTP.p('<div class="rowElem noborder" style="margin-top: 12px">');    
   HTP.p('  <label>'||qba_lang.MESSAGE (p_name => 'SYS.SELECTED_DATE')||'</label>');
   
   HTP.p('<input type="hidden" name="UserID" value='||QBA_SYSTEM.G_USER_ID||'>');
    
  HTP.p('<div class="formRight">');  --2
  HTP.p('        <input type="hidden" id="u_label" name="u_label" value="'||dater||'" style="width:60px; margin-left:19px"/>');
  HTP.p('        <input type=text readonly id="u_la" name="u_la" value="'||new_p_date||'" style="width:60px; margin-left:19px"/>');
  HTP.p('</div>');
  HTP.p ('                <div class="fix"></div>');
  HTP.p('</div>');
    
  HTP.p ('              <div class="rowElem noborder">');                
  HTP.p('                         <label>'||qba_lang.MESSAGE (p_name => 'SYS.AVAILABLE_TIME')||'</label>');
  HTP.p ('                <div class="formRight">');
  HTP.p('        <input type=text readonly id="n_start" name="n_start" value="'||rec.t_start||'" style="width:35px; margin-left:19px"/><span style=" margin-left:22px">--
                                   </span><input type=text readonly id="n_end" name="n_end" value="'||rec.t_end||'" style="width:35px; margin-left:26px"/>');
  HTP.p('       </div>'); --3
  HTP.p ('              <div class="fix"></div>');
  HTP.p(' </div>'); --2
  
      HTP.p ('              <div class="rowElem noborder">');                
 -- HTP.p('                         <label>'||qba_lang.MESSAGE (p_name => 'SYS.AVAILABLE_TIME')||'</label>');
  HTP.p ('                <div class="formRight">');
  HTP.p('        <input type="hidden" id="g_start" name="g_start" value="'||rec.n_start||'" style="width:35px; margin-left:19px"/><span style=" margin-left:22px">
                                   </span><input type= "hidden" id="g_end" name="g_end" value="'||rec.n_end||'" style="width:35px; margin-left:26px"/>');
  HTP.p('       </div>'); --3
  HTP.p ('              <div class="fix"></div>');
  HTP.p(' </div>'); --2
 
  
  
  
 
     endest := TO_CHAR(to_date(rec.t_end,'hh24:mi') - numtodsinterval(30,'MINUTE'),'hh24:mi');
     
    -- print_times(rec.t_start, endest,dater);
    
    --from here
    
    maxer := '23:30:00';
    miner := '00:00:00';
    
    HTP.p('<div class="rowElem noborder" style="margin-top: 12px">');     --1
    HTP.p('    <label>'||qba_lang.MESSAGE (p_name => 'SYS.SELECTED_TIME')||'</label>');
    HTP.p('<div class="formRight">');  --2
  
   if  to_date(rec.t_start, 'hh24:mi:ss') <=  to_date(endest, 'hh24:mi:ss') then 
   HTP.p('          <div style="float:left; margin-right: 10px; margin-top: 3px;"> <span>�</span>  </div>');
    HTP.p('                  <div style="float:left">');   --3
     qba_utils.htp_form_select_option (
      cname_ => 'u_subscriber_left'
     ,cvalue_ => p_time.id
     ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date('''||rec.t_start||''', ''hh24:mi:ss'') AND to_date ('''||endest||''', ''hh24:mi:ss'')'
   --  ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date(''00:00:00'', ''hh24:mi:ss'') AND to_date (''23:30:00'', ''hh24:mi:ss'')'
     ,cnull_ => FALSE                         -- HERE IS 
     ,cattributes_ => ' style="width: 62px " id="u_left"'
    );
   HTP.p('</div>'); --3
   
   end if;
 
  if  to_date(rec.t_start, 'hh24:mi:ss') >  to_date(endest, 'hh24:mi:ss') then 
  /* HTP.p('          <div style="float:left; margin-right: 10px; margin-top: 3px;"> <span>�</span>  </div>');
    HTP.p('                  <div style="float:left">');   --3
     qba_utils.htp_form_select_option (
      cname_ => 'u_subscriber_left'
     ,cvalue_ => p_time.id
     ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date('''||rec.t_start||''', ''hh24:mi:ss'') AND to_date ('''||maxer||''', ''hh24:mi:ss'') or 
      to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date('''||miner||''', ''hh24:mi:ss'') AND to_date ('''||rec.t_start||''', ''hh24:mi:ss'')'  
   --  ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date(''00:00:00'', ''hh24:mi:ss'') AND to_date (''23:30:00'', ''hh24:mi:ss'')'
     ,cnull_ => FALSE                         -- HERE IS 
     ,cattributes_ => ' style="width: 62px " id="u_left"'
    );
   HTP.p('</div>'); --3 */
   
   
   HTP.p('          <div style="float:left; margin-right: 10px; margin-top: 3px;"> <span>�</span>  </div>');
    HTP.p('                  <div style="float:left">');   --3
     qba_utils.htp_form_select_option (
      cname_ => 'u_subscriber_left'
     ,cvalue_ => p_time.id
     ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date('''||rec.t_start||''', ''hh24:mi:ss'') AND to_date ('''||maxer||''', ''hh24:mi:ss'')
     union all 
      select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date('''||miner||''', ''hh24:mi:ss'') AND to_date ('''||rec.t_end||''', ''hh24:mi:ss'')'  
   --  ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date(''00:00:00'', ''hh24:mi:ss'') AND to_date (''23:30:00'', ''hh24:mi:ss'')'
     ,cnull_ => FALSE                         -- HERE IS 
     ,cattributes_ => ' style="width: 62px " id="u_left"'
    );
   HTP.p('</div>'); --3
   
   end if;  
   
   
   
   
   
    --to here
     
       HTP.p('<div style="float:left;  margin-right: 10px; margin-top: 3px;">
                                            <span style="margin-left:10px"> + </span>
                                        </div>');
     
         HTP.p('<div style="float:left">');   --5
      HTP.p ('<input type="radio" name="u_type" checked="checked"  value="0" class="validate[required] radio" id="u_type"/><label>30 '||qba_lang.MESSAGE (p_name => 'SYS.MINUTES')||'</label><br />');
      
      if  ((to_date(rec.n_end,'hh24:mi') - to_date( rec.n_start,'hh24:mi')) * 1440)  >  35 then 
        HTP.p ('<input type="radio" name="u_type" checked="checked"  value="1" class="validate[required] radio" id="u_type"/><label>60  '||qba_lang.MESSAGE (p_name => 'SYS.MINUTES')||'</label><br />');
      end if ;
      
       if  ((to_date(rec.n_end,'hh24:mi') - to_date( rec.n_start,'hh24:mi')) * 1440)  >  65 then 
        HTP.p ('<input type="radio" name="u_type" checked="checked"  value="2" class="validate[required] radio" id="u_type"/><label>90  '||qba_lang.MESSAGE (p_name => 'SYS.MINUTES')||'</label><br />');
      end if ;
      
      HTP.p ('              </div>'); --5
      
    /*   HTP.p (
           '      <a href="#" onclick="$(''#frm_new'').submit();return false;" title="">'
        || '<input type="button" value="'
        || qba_lang.MESSAGE (p_name => 'SYS.SAVE')
        || '" class="seaBtn" /></a>'
      );   */
      
      HTP.p('</div>');
      HTP.p (  '<div class="rowElem noborder "  style="margin-top: 12px"><a href="#" onclick="$(''#frm_new'').submit();return false;" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.SAVE')|| '" class="seaBtn" /></a>' );
     --  HTP.p (  '<a href=" '||tm_common_v2.c#base_path|| c#package || '.html" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.CANCEL')|| '" class="seaBtn" /></a></div></br>' );
       
          HTP.p (  '<a href=" '||tm_common_v2.c#base_path|| c#package || '.print_choose_calendar?doc_num='||num_doctor||'" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.CANCEL')|| '" class="seaBtn" /></a></div></br>' );
      
      
   --   HTP.p (  '<div class="rowElem noborder "  style="margin-top: 12px"><a href="#" onclick="$(''#frm_new'').submit();return false;" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.SAVE')|| '" class="seaBtn" /></a></div><br/>' );
   /*
    HTP.p ('              <div class="rowElem noborder">');                
 -- HTP.p('                         <label>'||qba_lang.MESSAGE (p_name => 'SYS.AVAILABLE_TIME')||'</label>');
  HTP.p ('                <div class="formRight">');
  HTP.p('        <input type=text readonly id="g_start" name="g_start" value="'||rec.n_start||'" style="width:35px; margin-left:19px"/><span style=" margin-left:22px">
                                   </span><input type=text readonly id="g_end" name="g_end" value="'||rec.n_end||'" style="width:35px; margin-left:26px"/>');
  HTP.p('       </div>'); --3
  HTP.p ('              <div class="fix"></div>');
  HTP.p(' </div>'); --2*/
   
   
   
    
   end loop; 
    
    HTP.p('          </fieldset>');
    HTP.p('</form>');
    
   
    
   HTP.p('  <div class="fix"></div>');
   
                               
   HTP.p('</div>');  --1
   
    
   

    tm_common_v2.page_footer;
  END new_date;
  
    PROCEDURE delete_date(p_date IN VARCHAR2 := '', doc_id IN NUMBER := qba_system.g_user_id)  AS
     my_date DATE;
    endest varchar(20) := '';
    minut number(30);
    times          tm_doc_free_time%ROWTYPE;
    
    changer  varchar2(20);
    
    BEGIN
    
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    
    tm_common_v2.init;
    tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.SELECT_TIME'), p_left_menu_num => 0, prc_callback => 'tm_videoconference_v2.header_callback');
    
    pkg_date   := TO_DATE (p_date, 'dd.mm.yyyy');
    
    
    
    HTP.p('<div class="widget ">');    --1
    
    
   
    FOR rec IN (SELECT TO_CHAR (tdf.date_from, 'HH24:MI') AS t_start, TO_CHAR (tdf.date_to, 'HH24:MI') AS t_end
                  FROM tm_doc_free_time tdf
                 WHERE TO_CHAR (tdf.date_from, 'dd.mm.yyyy') = TO_CHAR (pkg_date, 'dd.mm.yyyy')) LOOP 
                 
                
    HTP.p('  <div class="rowElem noborder " style="margin-top: 12px">');  --2             
    
    HTP.p('<label id ="deleteYear" >'||TO_CHAR (pkg_date, 'dd.mm.yyyy')||'</label></br>');             
    HTP.p('    <label>'||qba_lang.MESSAGE (p_name => 'SYS.AVAILABLE_TIME')||'</label>');
    
    HTP.p('      <div class="formRight" style="margin-top: 0px; width: 350px;">'); --3            
                 
    
    
    HTP.p('        <input type="text" id="val1" value="'||rec.t_start||'" disabled="readonly" style="width:35px; margin-left:19px"><span style=" margin-left:22px">--
                                   </span><input type="text" id="val2" value="'||rec.t_end||'" disabled="readonly" style="width:35px; margin-left:26px">');
                                   
           
    HTP.p('       </div>'); --3
    HTP.p(' </div>'); --2
    
    
     changer := TO_CHAR (pkg_date, 'dd.mm.yyyy') || rec.t_start;
    
     endest := TO_CHAR(to_date(rec.t_end,'hh24:mi') - numtodsinterval(30,'MINUTE'),'hh24:mi');
     
   --  print_times(rec.t_start, endest);
    
    --HTP.p('  <div class="fix"></div>');
    
   end loop; 
    
    
--   HTP.p('<div class="rowElem noborder "  style="margin-top: 12px" id = "pusher"><a href="'||tm_common_v2.c#base_path|| c#package||'.html"  title=""><input type="button" value="��" class="redBtn" ></a></div>');  
   
   HTP.p ('<div class="rowElem noborder "  style="margin-top: 12px"><a href="'|| tm_common_v2.c#base_path|| c#package|| '.html" title=""><input type="button" id="pushDEL"  value="'|| qba_lang.MESSAGE (p_name => 'SYS.REJECT')|| '" class="redBtn" /></a>');
   
    HTP.p ('<a href="'|| tm_common_v2.c#base_path|| c#package|| '.change_status?ch_time='||changer||'" title=""><input type="button" id="pushACCEPT"  value="'|| qba_lang.MESSAGE (p_name => 'SYS.ACCEPT')|| '" class="redBtn" /></a></div></br>');         
    
   HTP.p('  <div class="fix"></div>');
   
                               
   HTP.p('</div>');  --1
   

    tm_common_v2.page_footer;
      END delete_date;
      
      
    PROCEDURE delete_date2(p_date IN VARCHAR2 := '', doctor IN NUMBER := qba_system.g_user_id,event_time varchar2 := '')  as       
       my_date DATE;
      endest varchar(20) := '';
      minut number(30);
      times          tm_doc_free_time%ROWTYPE;
      
       changer  varchar2(20);
       
       reco      tm_doc_free_time%ROWTYPE;
       pat_last_name varchar(20);
       
       begin
        IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    
    tm_common_v2.init;
    tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.SELECT_TIME'), p_left_menu_num => 0, prc_callback => 'tm_videoconference_v2.header_callback');
    
    pkg_date   := TO_DATE (p_date, 'dd.mm.yyyy');
    
    
    
    HTP.p('<div class="widget ">');    --1
  /*  FOR rec IN (SELECT TO_CHAR (tdf.date_from, 'HH24:MI') AS t_start, TO_CHAR (tdf.date_to, 'HH24:MI') AS t_end, TDF.PATIENT as patient
                  FROM tm_doc_free_time tdf
                 WHERE TO_CHAR (tdf.date_from, 'dd.mm.yyyy') = TO_CHAR (pkg_date, 'dd.mm.yyyy')  and TO_CHAR(TDF.DATE_FROM,'hh24:mi') = event_time and TDF.DOC_ID = doctor)  LOOP */
                 
   FOR rec IN (SELECT TO_CHAR (trunc_ts_tz (tdf.date_from, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN') AS t_start, TO_CHAR (trunc_ts_tz (tdf.date_to, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN')  AS t_end, TDF.PATIENT as patient,
    TO_CHAR(tdf.date_from,'hh24:mi') as n_start, TO_CHAR(tdf.date_to,'hh24:mi') as n_end
                  FROM tm_doc_free_time tdf
                 WHERE TO_CHAR (tdf.date_from, 'dd.mm.yyyy') = TO_CHAR (pkg_date, 'dd.mm.yyyy')  and TO_CHAR(TDF.DATE_FROM,'hh24:mi') = event_time and TDF.DOC_ID = doctor)  LOOP 
                 
                 
/*     select * in reco   FROM tm_doc_free_time tdf
                 WHERE TO_CHAR (tdf.date_from, 'dd.mm.yyyy') = TO_CHAR (pkg_date, 'dd.mm.yyyy')  and TO_CHAR(TDF.DATE_FROM,'hh24:mi') = event_time and TDF.DOC_ID = doctor;     */  
                 
  HTP.p ('      <form id="frm_delete_date" action="' || tm_common_v2.c#base_path|| 'dyn/' ||c#package ||'.remove_event" method="post" class="mainForm">');
  HTP.p ('        <fieldset>'); 
  
  IF rec.patient is not null then
  
  select QA.LAST_NAME into pat_last_name  from qba_users qa where QA.USER_ID = rec.patient;
  
  HTP.p('                 <div class="rowElem noborder " style="margin-top: 12px">');  --2  
  HTP.p('                        <label>'||qba_lang.MESSAGE (p_name => 'SYS.PARTICIPANT')||'</label>');
  HTP.p ('              <div class="formRight">');
  HTP.p('                           <input type= text readonly value="'||pat_last_name||'" name="deleteYear" id="deleteYear" />');
  HTP.p('                 </div>');         
  HTP.p ('                <div class="fix"></div>');
  HTP.p('</div>'); 
 
 end if;
 
  HTP.p('                 <div class="rowElem noborder " style="margin-top: 12px">');  --2  
  HTP.p('                        <label>'||qba_lang.MESSAGE (p_name => 'SYS.SELECTED_DATE')||'</label>');
  HTP.p ('              <div class="formRight">');
  HTP.p('                           <input type= text readonly  value="'||TO_CHAR (pkg_date, 'dd.mm.yyyy')||'" name="dY" id="dY" />');
  HTP.p('                           <input type= "hidden" value="'||TO_CHAR (pkg_date, 'yyyy.mm.dd')||'" name="deleteYear" id="deleteYear" />');
  HTP.p('                 </div>');         
  HTP.p ('                <div class="fix"></div>');
  HTP.p('</div>'); 
 
 
 
 /* 
  HTP.p('                 <div class="rowElem noborder " style="margin-top: 12px">');  --2  
--  HTP.p('                        <label>'||qba_lang.MESSAGE (p_name => 'SYS.SELECTED_DATE')||'</label>');
  HTP.p ('              <div class="formRight">');
  
  HTP.p('                 </div>');         
    HTP.p ('                <div class="fix"></div>');
    HTP.p('</div>');    
  */  
     HTP.p('  <div class="rowElem noborder " style="margin-top: 12px">');  --2  
    HTP.p('          <label>'||qba_lang.MESSAGE (p_name => 'SYS.AVAILABLE_TIME')||'</label>');
    HTP.p ('                <div class="formRight">');
    HTP.p('        <input type= text readonly id="val1" name="val1" value="'||rec.t_start||'" style="width:35px; margin-left:19px"/><span style=" margin-left:22px">
                                   </span><input type=text readonly id="val2" name="val2" value="'||rec.t_end||'" style="width:35px; margin-left:26px"/>');
    HTP.p('       </div>'); --3
    HTP.p ('              <div class="fix"></div>');
    HTP.p(' </div>'); --2
    
    HTP.p('  <div class="rowElem noborder " style="margin-top: 12px">');  --2  
 --   HTP.p('          <label>'||qba_lang.MESSAGE (p_name => 'SYS.AVAILABLE_TIME')||'</label>');
    HTP.p ('                <div class="formRight">');
    HTP.p('        <input type= "hidden" id="gval1" name="gval1" value="'||rec.n_start||'" style="width:35px; margin-left:19px"/><span style=" margin-left:22px">
                                   </span><input type= "hidden" id="gval2" name="gval2" value="'||rec.n_end||'" style="width:35px; margin-left:26px"/>');
    HTP.p('       </div>'); --3
    HTP.p ('              <div class="fix"></div>');
    HTP.p(' </div>'); --2
 
    changer := TO_CHAR (pkg_date, 'dd.mm.yyyy') || rec.n_start;
    
  /*  HTP.p (  '<div class="rowElem noborder "  style="margin-top: 12px"><a href="#" onclick="$(''#frm_delete_date'').submit();return false;" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.REJECT')|| '" class="seaBtn" /></a>' );
   HTP.p ('<a href="'|| tm_common_v2.c#base_path|| c#package|| '.change_status?ch_time='||changer||'" title=""><input type="button" id="pushACCEPT"  value="'|| qba_lang.MESSAGE (p_name => 'SYS.ACCEPT')|| '" class="redBtn" /></a></div><br/>');  */
 
   HTP.p (  '<div class="rowElem noborder "  style="margin-top: 12px"><a href="'|| tm_common_v2.c#base_path|| c#package|| '.change_status?ch_time='||changer||'" title=""><input type="button" id="pushACCEPT"  value="'|| qba_lang.MESSAGE (p_name => 'SYS.ACCEPT')|| '" class="redBtn" />' );
   HTP.p ('<a href="#" onclick="$(''#frm_delete_date'').submit();return false;" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.REJECT')|| '" class="seaBtn" /></a></a>
   <a href=" '||tm_common_v2.c#base_path|| c#package || '.html" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.CANCEL')|| '" class="seaBtn" /></a></div><br/>');   
    
    
    HTP.p('</fieldset>');
    HTP.p('</form>');
    
     
     endest := TO_CHAR(to_date(rec.t_end,'hh24:mi') - numtodsinterval(30,'MINUTE'),'hh24:mi');
  
   end loop; 
    
   HTP.p('  <div class="fix"></div>');
   
                               
   HTP.p('</div>');  --1
   

    tm_common_v2.page_footer;
       
          
          
       end delete_date2 ;
       
       
         
       PROCEDURE request(p_date IN VARCHAR2 := '', doctor IN NUMBER := QBA_SYSTEM.G_USER_ID, ident number)   as       
      my_date DATE;
      endest varchar(20) := '';
      minut number(30);
      times          tm_doc_free_time%ROWTYPE;
      
       changer  varchar2(20);
       
       reco      tm_doc_free_time%ROWTYPE;
       pat_last_name varchar(20);
       
       date_show varchar2(20);
       date_work varchar2(20);
   
     begin
        IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    tm_common_v2.init;
    tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.SELECT_TIME'), p_left_menu_num => 0, prc_callback => 'tm_videoconference_v2.header_callback');
    
    pkg_date   := TO_DATE (p_date, 'dd.mm.yyyy');
    
    
    
    HTP.p('<div class="widget ">');    --1
                 
   FOR rec IN (SELECT TO_CHAR (trunc_ts_tz (tdf.date_from, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN') AS t_start, TO_CHAR (trunc_ts_tz (tdf.date_to, 'MI', 'CURRENT'), 'hh24:mi', 'NLS_DATE_LANGUAGE = AMERICAN')  AS t_end, TDF.PATIENT as patient,
    TO_CHAR(tdf.date_from,'hh24:mi') as n_start, TO_CHAR(tdf.date_to,'hh24:mi') as n_end, TO_CHAR(TDF.DATE_FROM,'yyyy.mm.dd') as worker, TO_CHAR(TDF.DATE_FROM,'dd.mm.yyyy') as shower
                  FROM tm_doc_free_time tdf 
                 WHERE TDF.ID = ident and TDF.DOC_ID = doctor  ) LOOP 
       
    
                 
/*     select * in reco   FROM tm_doc_free_time tdf
                 WHERE TO_CHAR (tdf.date_from, 'dd.mm.yyyy') = TO_CHAR (pkg_date, 'dd.mm.yyyy')  and TO_CHAR(TDF.DATE_FROM,'hh24:mi') = event_time and TDF.DOC_ID = doctor;     */  
                 
  HTP.p ('      <form id="frm_delete_date" action="' || tm_common_v2.c#base_path|| 'dyn/' ||c#package ||'.remove_event" method="post" class="mainForm">');
  HTP.p ('        <fieldset>'); 
  
  IF rec.patient is not null then
  
  select QA.LAST_NAME into pat_last_name  from qba_users qa where QA.USER_ID = rec.patient;
  
  HTP.p('                 <div class="rowElem noborder " style="margin-top: 12px">');  --2  
  HTP.p('                        <label>'||qba_lang.MESSAGE (p_name => 'SYS.PARTICIPANT')||'</label>');
  HTP.p ('              <div class="formRight">');
  HTP.p('                           <input type= text readonly value="'||pat_last_name||'" name="deleteYear" id="deleteYear" />');
  HTP.p('                 </div>');         
  HTP.p ('                <div class="fix"></div>');
  HTP.p('</div>'); 
 
 end if;
 
  HTP.p('                 <div class="rowElem noborder " style="margin-top: 12px">');  --2  
  HTP.p('                        <label>'||qba_lang.MESSAGE (p_name => 'SYS.SELECTED_DATE')||'</label>');
  HTP.p ('              <div class="formRight">');
--  HTP.p('                           <input type= text readonly  value="'||TO_CHAR (pkg_date, 'dd.mm.yyyy')||'" name="dY" id="dY" />');
--  HTP.p('                           <input type= "hidden" value="'||TO_CHAR (pkg_date, 'yyyy.mm.dd')||'" name="deleteYear" id="deleteYear" />');
  
    HTP.p('                           <input type= text readonly  value="'||rec.shower||'" name="dY" id="dY" />');
  HTP.p('                           <input type= "hidden" value="'||rec.worker||'" name="deleteYear" id="deleteYear" />');
  
  HTP.p('                 </div>');         
  HTP.p ('                <div class="fix"></div>');
  HTP.p('</div>'); 
 
 
 
 /* 
  HTP.p('                 <div class="rowElem noborder " style="margin-top: 12px">');  --2  
--  HTP.p('                        <label>'||qba_lang.MESSAGE (p_name => 'SYS.SELECTED_DATE')||'</label>');
  HTP.p ('              <div class="formRight">');
  
  HTP.p('                 </div>');         
    HTP.p ('                <div class="fix"></div>');
    HTP.p('</div>');    
  */  
     HTP.p('  <div class="rowElem noborder " style="margin-top: 12px">');  --2  
    HTP.p('          <label>'||qba_lang.MESSAGE (p_name => 'SYS.AVAILABLE_TIME')||'</label>');
    HTP.p ('                <div class="formRight">');
    HTP.p('        <input type= text readonly id="val1" name="val1" value="'||rec.t_start||'" style="width:35px; margin-left:19px"/><span style=" margin-left:22px">
                                   </span><input type=text readonly id="val2" name="val2" value="'||rec.t_end||'" style="width:35px; margin-left:26px"/>');
    HTP.p('       </div>'); --3
    HTP.p ('              <div class="fix"></div>');
    HTP.p(' </div>'); --2
    
    HTP.p('  <div class="rowElem noborder " style="margin-top: 12px">');  --2  
 --   HTP.p('          <label>'||qba_lang.MESSAGE (p_name => 'SYS.AVAILABLE_TIME')||'</label>');
    HTP.p ('                <div class="formRight">');
    HTP.p('        <input type= "hidden" id="gval1" name="gval1" value="'||rec.n_start||'" style="width:35px; margin-left:19px"/><span style=" margin-left:22px">
                                   </span><input type= "hidden" id="gval2" name="gval2" value="'||rec.n_end||'" style="width:35px; margin-left:26px"/>');
    HTP.p('       </div>'); --3
    HTP.p ('              <div class="fix"></div>');
    HTP.p(' </div>'); --2
 
    changer := rec.shower || rec.n_start;
    
  /*  HTP.p (  '<div class="rowElem noborder "  style="margin-top: 12px"><a href="#" onclick="$(''#frm_delete_date'').submit();return false;" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.REJECT')|| '" class="seaBtn" /></a>' );
   HTP.p ('<a href="'|| tm_common_v2.c#base_path|| c#package|| '.change_status?ch_time='||changer||'" title=""><input type="button" id="pushACCEPT"  value="'|| qba_lang.MESSAGE (p_name => 'SYS.ACCEPT')|| '" class="redBtn" /></a></div><br/>');  */
 
   HTP.p (  '<div class="rowElem noborder "  style="margin-top: 12px"><a href="'|| tm_common_v2.c#base_path|| c#package|| '.change_status?ch_time='||changer||'" title=""><input type="button" id="pushACCEPT"  value="'|| qba_lang.MESSAGE (p_name => 'SYS.ACCEPT')|| '" class="redBtn" />' );
   HTP.p ('<a href="#" onclick="$(''#frm_delete_date'').submit();return false;" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.REJECT')|| '" class="seaBtn" /></a></a>
   <a href=" '||tm_common_v2.c#base_path|| c#package || '.html" title="">'|| '<input type="button" value="'|| qba_lang.MESSAGE (p_name => 'SYS.CANCEL')|| '" class="seaBtn" /></a></div><br/>');   
    
    
    HTP.p('</fieldset>');
    HTP.p('</form>');
    
     
     endest := TO_CHAR(to_date(rec.t_end,'hh24:mi') - numtodsinterval(30,'MINUTE'),'hh24:mi');
  
   end loop; 
    
   HTP.p('  <div class="fix"></div>');
   
                               
   HTP.p('</div>');  --1
   

    tm_common_v2.page_footer;
       
          
    
    
         
         end request;
    
 
    
   

  PROCEDURE print_times (p_start IN VARCHAR2 := '00:00:00', p_end IN VARCHAR2 := '23:30:00', p_date in varchar2 :='') AS
    p_time tm_time_stamps%ROWTYPE;
    rec    tm_doc_free_time%ROWTYPE;
    today varchar(20);
    dater date;
    
    new_p_date varchar(20);
 BEGIN
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    new_p_date := TO_CHAR(TO_DATE(p_date,'yyyy.mm.dd'),'dd.mm.yyyy');
    
    HTP.p('<div class="rowElem noborder" style="margin-top: 12px">');     --1
    
    HTP.p('  <label>'||qba_lang.MESSAGE (p_name => 'SYS.SELECTED_DATE')||'</label>');
    
    HTP.p('<div class="formRight">');  --2
  --  HTP.p('     <textarea name="u_label" id ="u_label" rows="1" cols="10"  readonly="readonly"  >'||p_date||'</textarea>'); 
   HTP.p('     <input type= text readonly id="u_l" name="u_l" value="'||new_p_date||'" style="width:60px; margin-left:19px"/><span style=" margin-left:22px">');
    
    HTP.p('     <input type="hidden" id="u_label" name="u_label" value="'||p_date||'" style="width:60px; margin-left:19px"/><span style=" margin-left:22px">');
    HTP.p('</div>');
    HTP.p ('                <div class="fix"></div>');
    HTP.p('</div>');
    
    
    
    
    HTP.p('<div class="rowElem noborder" style="margin-top: 12px">');     --1
    HTP.p('    <label>'||qba_lang.MESSAGE (p_name => 'SYS.SELECTED_TIME')||'</label>');
    HTP.p('<div class="formRight">');  --2
  
   HTP.p('          <div style="float:left; margin-right: 10px; margin-top: 3px;"> <span>�</span>  </div>');
    HTP.p('                  <div style="float:left">');   --3
     qba_utils.htp_form_select_option (
      cname_ => 'u_subscriber_left'
     ,cvalue_ => p_time.id
     ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date('''||p_start||''', ''hh24:mi:ss'') AND to_date ('''||p_end||''', ''hh24:mi:ss'')'
   --  ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date(''00:00:00'', ''hh24:mi:ss'') AND to_date (''23:30:00'', ''hh24:mi:ss'')'
     ,cnull_ => FALSE                         -- HERE IS 
     ,cattributes_ => ' style="width: 62px " id="u_left"'
    );
   HTP.p('</div>'); --3
    
    
    IF tm_common_v2.c#user_profile.role_id in (1,2,3,4,5) THEN
    
    HTP.p('<div style="float:left;  margin-right: 10px; margin-top: 3px;"> <span style="margin-left:10px"> �� </span></div>');
    HTP.p('<div style="float:left">');     --4
    qba_utils.htp_form_select_option (
      cname_ => 'u_subscriber_right'
     ,cvalue_ => p_time.id
     ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date('''||p_start||''', ''hh24:mi:ss'') AND to_date ('''||p_end||''', ''hh24:mi:ss'')'
     ,cnull_ => FALSE
     ,cattributes_ => 'style="width: 62px " id="u_right" '
    );
    HTP.p('</div>');    --4
    END IF;
    
    HTP.p ('                <div class="fix"></div>');
    HTP.p ('              </div>');         
 END print_times;

  PROCEDURE add_time AS
    p_time tm_time_stamps%ROWTYPE;
  BEGIN
    HTP.p ('                 <label>' || qba_lang.MESSAGE (p_name => 'SYS.BEFORE') || '</label>  ');

    qba_utils.htp_form_select_option (
      cname_ => 'u_subscriber_id'
     ,cvalue_ => p_time.id
     ,sql_text => 'select TO_CHAR(TMP.DATST, ''hh24:mi'') as name  from tm_time_stamps tmp where to_date(TO_CHAR(TMP.DATST, ''hh24:mi:ss''),''hh24:mi:ss'') between  to_date (''12:00:00'', ''hh24:mi:ss'') AND to_date (''17:30:00'',''hh24:mi:ss'')'
     ,cnull_ => TRUE
     ,cattributes_ => 'style="width: 292px'
    );
  END add_time;


  FUNCTION get_read_only
    RETURN NUMBER AS
  BEGIN
    RETURN OWA_UTIL.ite (pkg_date IS NOT NULL AND pkg_date <> TRUNC (qba_system.g_sysdate), 1, 0);
  END get_read_only;

  FUNCTION return_doc (tmp IN VARCHAR2 := '')
    RETURN NUMBER AS
  BEGIN
    RETURN OWA_UTIL.ite (pkg_date IS NOT NULL AND pkg_date <> TRUNC (qba_system.g_sysdate), 1, 0);
  END return_doc;
  
  
 PROCEDURE doc_get_dates_list(p_user_id in  number := qba_system.g_user_id, name_array IN OWA.vc_arr, value_array IN OWA.vc_arr) AS
  
  u_id      NUMBER;
  dt_start  DATE;
  dt_end    DATE;
  jsonarray json_list;
  jsonobj   json;
  
  dend date;
  end_time varchar2(20);
  
  BEGIN
  IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    
    tm_common_v2.init;
    
   -- dt_start    := date_linux2oracle (TO_NUMBER (qba_utils.get_val_from_arr (name_array, value_array, 'start')));
   -- dt_end      := date_linux2oracle (TO_NUMBER (qba_utils.get_val_from_arr (name_array, value_array, 'end')));

    jsonarray   := json_list ();
    
     IF tm_common_v2.c#user_profile.role_id in(1,2,3,4,5) THEN
     
       FOR rec
      IN (SELECT TO_CHAR (trunc_ts_tz (dc.date_from, 'MI', 'CURRENT'), 'Dy, dd Mon yyyy hh24:mi:ss', 'NLS_DATE_LANGUAGE = AMERICAN') AS dt1
              --  ,TO_CHAR (dc.date_to, 'Dy, dd Mon yyyy hh24:mi:ss TZR') AS dt2
            --    ,TO_CHAR (dc.date_to, 'Dy, dd Mon yyyy hh24:mi:ss') AS dt2
                , TO_CHAR (trunc_ts_tz (dc.date_to, 'MI', 'CURRENT'), 'Dy, dd Mon yyyy hh24:mi:ss', 'NLS_DATE_LANGUAGE = AMERICAN') AS dt2
                ,TO_CHAR (dc.date_from, 'yyyy/mm/dd') AS dt3
                ,dc.doc_id AS doctor,DC.ACCEPTED as accepted
                ,to_char(DC.DATE_FROM,'HH24:MI') as event_time
                ,DC.DATE_FROM as valid
                ,DC.DATE_TO as valid2
                ,DC.ID as IDENTIFICATOR
            FROM tm_doc_free_time dc where dc.doc_id = doc_get_dates_list.p_user_id) LOOP
      jsonobj   := json ();
      
      dend := TO_DATE(rec.dt2,'Dy, dd Mon yyyy hh24:mi:ss');
      end_time := TO_CHAR(dend,'hh24:mi');
     
     IF rec.valid >= sysdate then 
     
      jsonobj.put ('start', rec.dt1);
      jsonobj.put ('end', rec.dt2);
      jsonobj.put ('allDay', FALSE);
       if rec.accepted = 0 then
        jsonobj.put ('title', ' - '||end_time||'  '|| qba_lang.MESSAGE (p_name => 'SYS.FREE')||'');
       jsonobj.put ('color', '#4682B4');          
      end if;
      
       if rec.accepted = 1 then
     --  jsonobj.put ('title', 'pending');
        jsonobj.put ('title', ' - '||end_time|| '          '|| qba_lang.MESSAGE (p_name => 'SYS.PENDING')||'');
       jsonobj.put ('color', '#B55D5C');
      end if;
      
      if rec.accepted = 2 then
      

      
     --   jsonobj.put ('title', 'accepted');
        jsonobj.put ('title', ' - '||end_time|| '    '|| qba_lang.MESSAGE (p_name => 'SYS.ACCEPTED')||'');
       jsonobj.put ('color', '#228B22');
       end if;
    
    --   jsonobj.put ('url', tm_common_v2.c#base_path || rec.dt3 || '/' || c#package || '.delete_date2?event_time='||rec.event_time||'');
      
    -- jsonobj.put ('url', tm_common_v2.c#base_path ||rec.dt3 || '/' || c#package || '.request?ident='||rec.IDENTIFICATOR||'');
     
       jsonobj.put ('url', tm_common_v2.c#base_path || c#package || '.request?ident='||rec.IDENTIFICATOR||'');
     
      end if;
      
      if rec.valid2 < sysdate and rec.accepted = 2 then
      jsonobj.put ('start', rec.dt1);
       jsonobj.put ('end', rec.dt2);
       jsonobj.put ('title',  qba_lang.MESSAGE (p_name => 'SYS.FINISHED'));
       jsonobj.put ('color', '#8B6969');  
      
      end if;
      
       if rec.valid2 < sysdate and rec.accepted <> 2 then
      jsonobj.put ('start', rec.dt1);
       jsonobj.put ('end', rec.dt2);
       jsonobj.put ('title', qba_lang.MESSAGE (p_name => 'SYS.OVERDUE'));
       jsonobj.put ('color', '#483D8B');  
      
      end if;
   --    jsonobj.put ('url', tm_common_v2.c#base_path || rec.dt3 || '/' || c#package || '.delete_date');
      jsonarray.append (jsonobj.to_json_value);
    END LOOP;
     
   END IF; 
    
    
    
    
    
    jsonarray.HTP;
    
    
  
  END doc_get_dates_list;


  PROCEDURE close_connect AS
  BEGIN
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;

    HTP.p ('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
    HTP.p ('<html xmlns="http://www.w3.org/1999/xhtml">');
    HTP.p ('<head>');
    HTP.p ('<title></title>');
    HTP.p ('<script language="JavaScript" type="text/javascript">');



    HTP.p ('function get()');
    HTP.p ('{');
    HTP.p (' document.getElementById("mylink").click();');
    HTP.p ('};');

  

    HTP.p ('</script>');

    HTP.p ('</head>');

    HTP.p ('<body onload = "get()">');


    HTP.p ('<a onclick="window.focus(); parent.opener=window;parent.close();" href="javascript:void(0)"  id="mylink">Closed</a>');
    HTP.p ('</body>');
    HTP.p ('</html>');
  END close_connect;


  PROCEDURE print_doc_free_time (doc_id IN NUMBER) AS
  BEGIN
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
  END print_doc_free_time;
  
 
   PROCEDURE doc_add_time(date_f in varchar2 , date_t in varchar2, ymd in varchar2 ) as
   
   full_date_start varchar2(25);
   full_date_end varchar2 (25);
  
     BEGIN
   
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    tm_common_v2.init;
    
   --full_date_start := '2012.09.19'  || date_f;
  -- full_date_end :=  '2012.09.19'  ||  date_t; 
   
    full_date_start := ymd  || date_f;
    full_date_end :=  ymd  ||  date_t; 
    
 --   insert into tm_doc_free_time(doc_id,date_from,date_to) values(2, TO_DATE('2012.08.1115:30','YYYY.MM.DDHH24:MI'), TO_DATE('2012.08.1116:00', 'YYYY.MM.DDHH24:MI'));
 
     insert into tm_doc_free_time(doc_id,date_from,date_to) values(QBA_SYSTEM.G_USER_ID , TO_DATE(full_date_start, 'YYYY.MM.DDHH24:MI'), TO_DATE(full_date_end, 'YYYY.MM.DDHH24:MI'));
    
    commit;
   
   END doc_add_time;
  
  
  PROCEDURE upd_calendar (name_array IN OWA.vc_arr, value_array IN OWA.vc_arr) as
   
    ref_proc     VARCHAR2 (200);
    rec_p    tm_doc_free_time%ROWTYPE;
    
    gmt_rec_p tm_doc_free_time%ROWTYPE;
     nn       NUMBER;
    
    dater          varchar2 (20);
    time_from varchar2(20);
    time_to      varchar2(20);
    
    date_from varchar2(20);
    date_to      varchar2(20);
    
    conf_id number;
    
    timezone varchar2(10byte);
   
    GMT varchar2(10byte);
    GMT1 varchar2(10byte);
    GMT4 varchar2(10byte);
   
   begin 
   
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    tm_common_v2.init;
  
     ref_proc         := qba_utils.get_val_from_arr (name_array, value_array, 'ref_proc');
  --   rec_p.id         := qba_utils.get_val_from_arr (name_array, value_array, 'prid');
  
  GMT := '+00:00';
  GMT1 := '+01:00';
  GMT4 := '+04:00';
  
  select NVL (uu.user_time_zone, qba_utils.get_preference ('SYSTEM_TIME_ZONE')) into timezone from qba_users uu where UU.USER_ID =QBA_SYSTEM.G_USER_ID;
     
       FOR nn IN name_array.FIRST .. name_array.LAST LOOP
        CASE name_array (nn)
           when 'u_label' then
              dater := value_array (nn);
            when 'u_subscriber_left' then
              time_from := value_array(nn);
            when 'u_subscriber_right' then
              time_to := value_array(nn);   
          else null;
          end case;   
          end loop;
          
          
        --  if   timezone = GMT then
          date_from := dater || time_from;
          date_to     :=  dater || time_to;
          
          rec_p.date_from := TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi');     
          rec_p.date_to     := TO_TIMESTAMP( date_to, 'yyyy.mm.ddhh24:mi');
          
          gmt_rec_p.date_from := FROM_TZ(SYS_EXTRACT_UTC (rec_p.date_from) , 'GMT');
          gmt_rec_p.date_to := FROM_TZ(SYS_EXTRACT_UTC (rec_p.date_to) , 'GMT');
          
        --  end if;
       /*   
          if  timezone = GMT1 then 
           rec_p.date_from := TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi ')  + INTERVAL '0 01:00:00' DAY TO SECOND;   
           rec_p.date_to     := TO_TIMESTAMP( date_to, 'yyyy.mm.ddhh24:mi ')  + INTERVAL '0 01:00:00' DAY TO SECOND;
         end if;
         
         if  timezone = GMT4 then 
           rec_p.date_from := TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi tzh:tzm')  + INTERVAL '0 04:00:00' DAY TO SECOND;   
           rec_p.date_to     := TO_TIMESTAMP( date_to, 'yyyy.mm.ddhh24:mi tzh:tzm')  + INTERVAL '0 04:00:00' DAY TO SECOND;
         end if;
         */ 
          
        --  select TDF.ID into conf_id from tm_doc_free_time tdf where TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi') = TO_TIMESTAMP(TO_CHAR(TDF.DATE_FROM,'yyyy.mm.ddhh24:mi'),'yyyy.mm.ddhh24:mi');
        
        
          
       --      select nvl(TDF.ID,0) into conf_id from tm_doc_free_time tdf where rec_p.date_from = TDF.DATE_FROM;
       
        select count(TDF.ID) into conf_id from tm_doc_free_time tdf where rec_p.date_from = TDF.DATE_FROM;
       
     
             
     IF conf_id = 0 then
          
          IF rec_p.date_from < rec_p.date_to then 
          
            IF rec_p.id IS NULL THEN
        INSERT
          INTO tm_doc_free_time (id,
                                doc_id,
                                date_from,
                                date_to,
                                accepted
                                )
        VALUES (
                 NULL,
                 qba_system.g_user_id,
                 gmt_rec_p.date_from,
                 gmt_rec_p.date_to,
                 0
              );  
         else 
         null;
         end if;       
         
         commit;
         
              qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
          
             qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.ALL_CHANGES_SAVED'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
           sys.OWA_UTIL.http_header_close;
         
         else   
         qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
         qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.INVALID_TIME'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
                              
            sys.OWA_UTIL.http_header_close;                  
         
         end if;
         
         else
         
         qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
         qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.INVALID_TIME'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
                              
            sys.OWA_UTIL.http_header_close;  
         
         end if;
        
    
   
   end upd_calendar;
   
   PROCEDURE concat_times as
    nn NUMBER;

   cursor c1 return  tm_doc_free_time%ROWTYPE
    IS select * from tm_doc_free_time tdf where TDF.ACCEPTED = 0 order by TDF.DATE_FROM; 
   
   begin
   
     IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    FOR rec IN (  SELECT *
                  FROM tm_doc_free_time tdf where TDF.ACCEPTED = 0
              ORDER BY TDF.DATE_FROM DESC) LOOP
    SELECT MIN(TDF.ID)
      INTO nn
      FROM tm_doc_free_time tdf
     WHERE TO_CHAR(tdf.date_from,'yyyy.mm.dd hh24:mi') = TO_CHAR(rec.date_to,'yyyy.mm.dd hh24:mi') and TDF.ACCEPTED = 0 ; 

    IF nn IS NOT NULL THEN
        UPDATE tm_doc_free_time tdf set TDF.DATE_FROM = rec.date_from where TDF.ID = nn;
        delete from tm_doc_free_time tdf where TDF.ID = rec.id; 
    END IF;
  END LOOP;

     
    commit;
    
    
   
   end concat_times;
   
  
   PROCEDURE choose_interval(name_array IN OWA.vc_arr, value_array IN OWA.vc_arr,doc_id number := 2) as                     --it was doc_id = 2
    
    ref_proc     VARCHAR2 (200);
    rec_p    tm_doc_free_time%ROWTYPE;
    gmt_rec_p  tm_doc_free_time%ROWTYPE;
     nn       NUMBER;
    
    dater          varchar2 (20);   --+
    time_from varchar2(20);    --+
    option_time number;          --+
    interval_start varchar2(20); --+
    interval_end varchar2(20); --+
    
    date_for_ref varchar2(20);
    dater1 varchar2(20);
    dater2 varchar2(20);
    
    interval_timezone_start varchar2(20);
    interval_timezone_end varchar2(20);
    
    freetime_start varchar2(20);
    freetime_end  varchar2(20);
    rec_id number;
    
    freetime_gmt_start varchar2(20);
    freetime_gmt_end varchar2(20);
    
     time_to      varchar2(20);
    date_from varchar2(20);
    date_to   timestamp with time zone;
    
    patient number;
    
    doctor number;
    
    local_data date;
    
    redirect_date varchar2(20);
    redirecting varchar2(20);
    
    ref_conf_id number;
    
    begin
     
       IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    
    select TVS.LAS_VISIT into doctor from tm_video_session tvs where TVS.SESSION_ID = 1;
    
      tm_common_v2.init;
    
     FOR nn IN name_array.FIRST .. name_array.LAST LOOP
        CASE name_array (nn)
           when 'u_label' then
              dater := value_array (nn);
            when 'u_subscriber_left' then
              time_from := value_array(nn);
            when 'u_type' then
              option_time := to_number(value_array(nn));   
            when 'g_start' then
               interval_start := value_array(nn);
            when 'g_end' then
               interval_end := value_array(nn);  
             
            when 'n_start' then
               interval_timezone_start := value_array(nn);
            when 'n_end' then
               interval_timezone_end := value_array(nn);    
               
            when 'UserID' then
                patient := value_array(nn);   
        else null;
          end case;   
          end loop;
          
          if TO_DATE(interval_start,'hh24:mi') > TO_DATE(interval_timezone_start,'hh24:mi') and TO_DATE(interval_end,'hh24:mi') > TO_DATE(interval_timezone_end,'hh24:mi')  then
          
          local_data := TO_DATE(dater,'yyyy.mm.dd');
          local_data := local_data  - 1;
          dater := TO_CHAR(local_data,'yyyy.mm.dd');
          
          dater1 := dater;
          dater2 := dater;
          end if;
          
            if TO_DATE(interval_start,'hh24:mi') <= TO_DATE(interval_timezone_start,'hh24:mi') and TO_DATE(interval_end,'hh24:mi') <= TO_DATE(interval_timezone_end,'hh24:mi')  then
          
            dater1 := dater;
            dater2 := dater;          
          
          end if;
          
            if TO_DATE(interval_start,'hh24:mi') < TO_DATE(interval_timezone_start,'hh24:mi') and TO_DATE(interval_end,'hh24:mi') > TO_DATE(interval_timezone_end,'hh24:mi')  then
          
            dater1 := dater;
            dater2 := dater;          
          
          end if;
          
          
          
          redirect_date := dater;
          
          date_from := dater1 || time_from;
          
          freetime_start := dater1 || interval_start;
          
          freetime_end := dater2 || interval_end;
          
          freetime_gmt_start := dater1 || interval_timezone_start;
          freetime_gmt_end  := dater2 || interval_timezone_end; 
         
         
        rec_p.date_from := TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi');
        
          if  option_time = 0 then
            rec_p.date_to := TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi') + INTERVAL '0 00:30:00' DAY TO SECOND;
          
          elsif   option_time = 1 then
             rec_p.date_to := TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi') + INTERVAL '0 01:00:00' DAY TO SECOND;
    
          elsif option_time = 2 then
             rec_p.date_to := TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi') + INTERVAL '0 01:30:00' DAY TO SECOND;
            
            end if; 
            
            
          gmt_rec_p.date_from := FROM_TZ(SYS_EXTRACT_UTC (rec_p.date_from) , 'GMT');
          gmt_rec_p.date_to := FROM_TZ(SYS_EXTRACT_UTC (rec_p.date_to) , 'GMT');
            
            
  --         IF gmt_rec_p.date_to <=  FROM_TZ(SYS_EXTRACT_UTC(TO_TIMESTAMP(freetime_end,'yyyy.mm.ddhh24:mi')),'GMT') then
  
        IF gmt_rec_p.date_to <= FROM_TZ(TO_TIMESTAMP(freetime_end,'yyyy.mm.ddhh24:mi'),'GMT')  then
    
            
            select TDF.ID into rec_id   from tm_doc_free_time tdf where to_char(TDF.DATE_FROM,'yyyy.mm.ddhh24:mi' ) = freetime_start and TDF.DOC_ID = doctor;
            
             IF interval_timezone_start = time_from and interval_end <> TO_CHAR(gmt_rec_p.date_to,'hh24:mi')    THEN
              delete from tm_doc_free_time tdf where TDF.ID = rec_id;
              
             INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted,patient)
              VALUES ( NULL, doctor, gmt_rec_p.date_from, gmt_rec_p.date_to,1,QBA_SYSTEM.G_USER_ID);                                                           -- doc_id ---> doctor
              
              select TD.ID into ref_conf_id from tm_doc_free_time td where TD.DOC_ID = doctor and TD.DATE_FROM = gmt_rec_p.date_from;
               
             INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted)
         --    VALUES ( NULL, doctor,gmt_rec_p.date_to,TO_TIMESTAMP(freetime_end,'yyyy.mm.ddhh24:mi'),0);  
             
             VALUES ( NULL, doctor,gmt_rec_p.date_to,  FROM_TZ(SYS_EXTRACT_UTC (TO_TIMESTAMP(freetime_gmt_end,'yyyy.mm.ddhh24:mi') ) , 'GMT') ,0);  
               
             END IF ;
          
          
              IF interval_timezone_start <> time_from and interval_end <>TO_CHAR(gmt_rec_p.date_to,'hh24:mi')    THEN
              delete from tm_doc_free_time tdf where TDF.ID = rec_id;
              
             INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted)
      --        VALUES ( NULL, doctor, TO_TIMESTAMP(freetime_start,'yyyy.mm.ddhh24:mi'), rec_p.date_from,0 );  
             VALUES ( NULL, doctor,FROM_TZ(SYS_EXTRACT_UTC (TO_TIMESTAMP(freetime_gmt_start,'yyyy.mm.ddhh24:mi') ) , 'GMT')  , gmt_rec_p.date_from,0 );  
               
             INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted,patient)
             VALUES ( NULL, doctor, gmt_rec_p.date_from,gmt_rec_p.date_to,1,QBA_SYSTEM.G_USER_ID);
             
             select TD.ID into ref_conf_id from tm_doc_free_time td where TD.DOC_ID = doctor and TD.DATE_FROM = gmt_rec_p.date_from;
             
             INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted)
    --         VALUES ( NULL, doctor, gmt_rec_p.date_to,TO_TIMESTAMP(freetime_end,'yyyy.mm.ddhh24:mi'),0);
             VALUES ( NULL, doctor, gmt_rec_p.date_to, FROM_TZ(SYS_EXTRACT_UTC (TO_TIMESTAMP(freetime_gmt_end,'yyyy.mm.ddhh24:mi') ) , 'GMT'),0);
             
             END IF;
           
          
       
              IF interval_timezone_start <> time_from and interval_end =TO_CHAR(gmt_rec_p.date_to,'hh24:mi')    THEN
              delete from tm_doc_free_time tdf where TDF.ID = rec_id;
              
              INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted)
              VALUES ( NULL, doctor, FROM_TZ(SYS_EXTRACT_UTC (TO_TIMESTAMP(freetime_gmt_start,'yyyy.mm.ddhh24:mi') ) , 'GMT'), gmt_rec_p.date_from,0 );  
               
             INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted,patient)
             VALUES ( NULL, doctor, gmt_rec_p.date_from,gmt_rec_p.date_to,1,QBA_SYSTEM.G_USER_ID);
             
             select TD.ID into ref_conf_id from tm_doc_free_time td where TD.DOC_ID = doctor and TD.DATE_FROM = gmt_rec_p.date_from;
             
            END IF;
            
            
              IF interval_timezone_start = time_from and interval_end = TO_CHAR(gmt_rec_p.date_to,'hh24:mi')    THEN
              delete from tm_doc_free_time tdf where TDF.ID = rec_id;
              
             INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted,patient)
              VALUES ( NULL, doctor, gmt_rec_p.date_from, gmt_rec_p.date_to,1,QBA_SYSTEM.G_USER_ID);                                                           -- doc_id ---> doctor
              
              select TD.ID into ref_conf_id from tm_doc_free_time td where TD.DOC_ID = doctor and TD.DATE_FROM = gmt_rec_p.date_from;
              
             END IF ;
          
      TM_MESSAGES_V2.SEND_MESSAGE(QBA_SYSTEM.G_USER_ID,doctor,qba_lang.MESSAGE (p_name => 'SYS.APPVIDEO'),ref_conf_id);
          
        concat_times;
            
             
             
             commit;
               
                qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
          
                qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.ALL_CHANGES_SAVED'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
    sys.OWA_UTIL.http_header_close;
             
             
             
             
           else
             
         --    qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
         
              redirecting := TO_CHAR(TO_DATE(redirect_date,'yyyy.mm.dd'),'/yyyy/mm/dd');

              qba_utils.redirect_url (redirecting || tm_common_v2.c#base_path|| c#package || '.new_date?event_time='||interval_start||'' , FALSE);
              qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.INVALID_TIME'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
                              
            sys.OWA_UTIL.http_header_close;  
         
         end if;
             
             
             
            
           
             
             
          /*   
               commit;
               
                qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
          
                qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.ALL_CHANGES_SAVED'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
    sys.OWA_UTIL.http_header_close;         */
            
           
    end choose_interval;


/*
    PROCEDURE choose_interval(name_array IN OWA.vc_arr, value_array IN OWA.vc_arr,doc_id number := 2) as                     --it was doc_id = 2
    
    date_timezone varchar2(20);                  --date printed in page(with timezone)
    date_gmt      varchar2(20);                  --date in gmt
    
    time_from_timezone varchar2(20);             --time from hh:mm      
    option_time number;                          -- choosing interval 30 - 0, 60 - 1, 90 -2 
    
    interval_gmt_start varchar2(20);             -- begin of the free time in gmt
    interval_gmt_end varchar2(20);               -- end of the free time in gmt
    
    interval_timezone_start varchar2(20);        --begin of the free time in timezone   
    interval_timezone_end varchar2(20);          --end of the free time in timezone       
    
    patient number;                              --user id
    
    local_data date;                             --swap
    
    date_begin_timezone varchar2(20);            -- yyyy.mm.dd of interval start with timezone
    date_end_timezone varchar2(20);              -- yyyy.mm.dd of interval end whith timezone
    
    choose_start_timezone     varchar2(20);              -- choose time start in timezone 
    
    free_time_timezone_start  varchar2(20);
    free_time_timezone_end    varchar2(20);
    
    freetime_gmt_start varchar2(20);
    freetime_gmt_end varchar2(20);
    
    timezone_rec_p     tm_doc_free_time%ROWTYPE;
    gmt_rec_p          tm_doc_free_time%ROWTYPE;
    
    
    ref_proc     VARCHAR2 (200);
    rec_p    tm_doc_free_time%ROWTYPE;
 --   gmt_rec_p  tm_doc_free_time%ROWTYPE;
     nn       NUMBER;
   
   dater_swap varchar2(20);
    
    dater          varchar2 (20);   --+
    time_from varchar2(20);    --+
    
    interval_start varchar2(20); --+
    interval_end varchar2(20); --+
    
    date_for_ref varchar2(20);
    dater1 varchar2(20);
    dater2 varchar2(20);
    
    
    freetime_start varchar2(20);
    freetime_end  varchar2(20);
    rec_id number;
    
    
    
     time_to      varchar2(20);
    date_from varchar2(20);
    date_to   timestamp with time zone;
    
    
    
    doctor number;
    
    
    dater_gmt varchar2(20);
    dater_timezone varchar2(20);
    
   BEGIN                                             
     
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    
    select TVS.LAS_VISIT into doctor from tm_video_session tvs where TVS.SESSION_ID = 1; --obtain doctor id
    
    tm_common_v2.init;
    
     FOR nn IN name_array.FIRST .. name_array.LAST LOOP                                  --obtain data from json
        CASE name_array (nn)
           when 'u_label' then
              date_timezone := value_array (nn);
            when 'u_subscriber_left' then
              time_from_timezone := value_array(nn);
            when 'u_type' then
              option_time := to_number(value_array(nn));   
            when 'g_start' then
               interval_gmt_start := value_array(nn);
            when 'g_end' then
               interval_gmt_end := value_array(nn);  
            when 'n_start' then
               interval_timezone_start := value_array(nn);
            when 'n_end' then
               interval_timezone_end := value_array(nn);    
            when 'UserID' then
                patient := value_array(nn);   
        else null;
          end case;   
    end loop;
    
          
    if TO_DATE(interval_gmt_start,'hh24:mi') > TO_DATE(interval_timezone_start,'hh24:mi') and    --begin and end in gmt + 1 
       TO_DATE(interval_gmt_end,'hh24:mi') > TO_DATE(interval_timezone_end,'hh24:mi')  then
          
          local_data := TO_DATE(date_timezone,'yyyy.mm.dd');
          local_data := local_data  - 1;
          date_gmt := TO_CHAR(local_data,'yyyy.mm.dd');
          
          date_begin_timezone := date_timezone;
          date_end_timezone := date_timezone;
          
    end if;
          
   if TO_DATE(interval_start,'hh24:mi') <= TO_DATE(interval_timezone_start,'hh24:mi')and        -- begin and end in gmt
      TO_DATE(interval_end,'hh24:mi') <= TO_DATE(interval_timezone_end,'hh24:mi')  then
      
         date_gmt := date_timezone;
         date_begin_timezone := date_timezone;
         date_end_timezone   := date_timezone;   
                    
    end if;
          
   
   if TO_DATE(interval_start,'hh24:mi') < TO_DATE(interval_timezone_start,'hh24:mi') and        -- begin in gmt, end in gmt + 1
      TO_DATE(interval_end,'hh24:mi') > TO_DATE(interval_timezone_end,'hh24:mi')  then
         
         local_data := TO_DATE(date_timezone,'yyyy.mm.dd');
         local_data := local_data + 1;
         date_end_timezone := TO_CHAR(local_data,'yyyy.mm.dd');
         
         date_gmt := date_timezone;
         
         date_begin_timezone := date_gmt;
                
    end if;
          
          
          
          
          
    choose_start_timezone   := date_begin_timezone || time_from;
          
    free_time_timezone_start := date_begin_timezone || interval_timezone_start;
          
    free_time_timezone_end   := date_end_timezone   || interval_timezone_end;
          
    freetime_gmt_start      := date_gmt || interval_gmt_start;
    
    freetime_gmt_end        := date_gmt || interval_gmt_end; 
         
         
    timezone_rec_p.date_from := TO_TIMESTAMP(choose_start_timezone,'yyyy.mm.ddhh24:mi');
     
    --count the end of choosing time    
    if  option_time = 0 then
       timezone_rec_p.date_to := TO_TIMESTAMP(choose_start_timezone,'yyyy.mm.ddhh24:mi') + INTERVAL '0 00:30:00' DAY TO SECOND;
          
    elsif option_time = 1 then
       timezone_rec_p.date_to := TO_TIMESTAMP(choose_start_timezone,'yyyy.mm.ddhh24:mi') + INTERVAL '0 01:00:00' DAY TO SECOND;
    
    elsif option_time = 2 then
       timezone_rec_p.date_to := TO_TIMESTAMP(choose_start_timezone,'yyyy.mm.ddhh24:mi') + INTERVAL '0 01:30:00' DAY TO SECOND;
            
    end if; 
            
            
    gmt_rec_p.date_from := SYS_EXTRACT_UTC(timezone_rec_p.date_from);
    gmt_rec_p.date_to   := SYS_EXTRACT_UTC(timezone_rec_p.date_to);
            
            
    IF gmt_rec_p.date_to <=  FROM_TZ(TO_TIMESTAMP(freetime_gmt_end,'yyyy.mm.ddhh24:mi'),'GMT') then
    
       select TDF.ID into rec_id   from tm_doc_free_time tdf 
       where to_char(TDF.DATE_FROM,'yyyy.mm.ddhh24:mi') = freetime_gmt_start and TDF.DOC_ID = doctor;
            
       IF interval_timezone_start = time_from_timezone and interval_gmt_end <> TO_CHAR(gmt_rec_p.date_to,'hh24:mi') THEN
          delete from tm_doc_free_time tdf where TDF.ID = rec_id;
          
          INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted,patient)
          VALUES ( NULL, doctor, gmt_rec_p.date_from, gmt_rec_p.date_to,1,QBA_SYSTEM.G_USER_ID);                                   
               
          INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted)
          VALUES (NULL,doctor,gmt_rec_p.date_to,FROM_TZ(SYS_EXTRACT_UTC(TO_TIMESTAMP(freetime_gmt_end,'yyyy.mm.ddhh24:mi')),'GMT'),0);  
               
       END IF ;
          
          
       IF interval_timezone_start <> time_from_timezone and interval_gmt_end <> TO_CHAR(gmt_rec_p.date_to,'hh24:mi') THEN
          delete from tm_doc_free_time tdf where TDF.ID = rec_id;
              
          INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted)
          VALUES (NULL,doctor,FROM_TZ(SYS_EXTRACT_UTC(TO_TIMESTAMP(freetime_gmt_start,'yyyy.mm.ddhh24:mi')),'GMT'),gmt_rec_p.date_from,0);  
               
          INSERT INTO tm_doc_free_time (id, doc_id, date_from, date_to, accepted,patient)
          VALUES (NULL, doctor, gmt_rec_p.date_from, gmt_rec_p.date_to,1,QBA_SYSTEM.G_USER_ID);
             
          INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted)
          VALUES ( NULL, doctor, gmt_rec_p.date_to,FROM_TZ(SYS_EXTRACT_UTC(TO_TIMESTAMP(freetime_gmt_end,'yyyy.mm.ddhh24:mi')),'GMT'),0);
             
       END IF;
           
          
       
       IF interval_timezone_start <> time_from_timezone and interval_gmt_end =TO_CHAR(gmt_rec_p.date_to,'hh24:mi')    THEN
          delete from tm_doc_free_time tdf where TDF.ID = rec_id;
              
          INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted)
          VALUES ( NULL, doctor, FROM_TZ(SYS_EXTRACT_UTC (TO_TIMESTAMP(freetime_gmt_start,'yyyy.mm.ddhh24:mi')),'GMT'),gmt_rec_p.date_from,0 );  
               
          INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted,patient)
          VALUES ( NULL, doctor, gmt_rec_p.date_from,gmt_rec_p.date_to,1,QBA_SYSTEM.G_USER_ID);
             
       END IF;
            
            
       IF interval_timezone_start = time_from_timezone and interval_gmt_end = TO_CHAR(gmt_rec_p.date_to,'hh24:mi')    THEN
          delete from tm_doc_free_time tdf where TDF.ID = rec_id;
              
          INSERT INTO tm_doc_free_time (id,  doc_id,  date_from, date_to, accepted,patient)
          VALUES(NULL, doctor, gmt_rec_p.date_from, gmt_rec_p.date_to,1,QBA_SYSTEM.G_USER_ID);  
       END IF ;
            
            
       TM_MESSAGES_V2.SEND_MESSAGE(QBA_SYSTEM.G_USER_ID,doctor,qba_lang.MESSAGE (p_name => 'SYS.APPVIDEO'));
             
       commit;
               
       qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
          
       qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.ALL_CHANGES_SAVED'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
       sys.OWA_UTIL.http_header_close;
             
             
             
             
       else
             
     

       qba_utils.redirect_url ( tm_common_v2.c#base_path|| c#package || '.print_choose_calendar?doc_num='||doctor||'' , FALSE);
       qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.INVALID_TIME'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
                              
       sys.OWA_UTIL.http_header_close;  
         
   end if;
       
    end choose_interval;
*/    
   
     PROCEDURE remove_event (name_array IN OWA.vc_arr, value_array IN OWA.vc_arr) as
  
    ref_proc     VARCHAR2 (200);
    rec_p    tm_doc_free_time%ROWTYPE;
    gmt_rec_p  tm_doc_free_time%ROWTYPE;
     nn       NUMBER;
    
    dater          varchar2 (20);
    time_from varchar2(20);
    time_to      varchar2(20);
    
    date_from varchar2(20);
    date_to      varchar2(20);
    
    ident number;
    mpatient  number;
  
  begin
  
   IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
     tm_common_v2.init;
  
     ref_proc         := qba_utils.get_val_from_arr (name_array, value_array, 'ref_proc');
  --   rec_p.id         := qba_utils.get_val_from_arr (name_array, value_array, 'prid');
     
       FOR nn IN name_array.FIRST .. name_array.LAST LOOP
        CASE name_array (nn)
           when 'deleteYear' then
              dater := value_array (nn);
            when 'gval1' then
              time_from := value_array(nn);
            when 'gval2' then
              time_to := value_array(nn);   
          else null;
          end case;   
          end loop;
          
          date_from := dater || time_from;
          date_to     :=  dater || time_to;
          
          rec_p.date_from := TO_TIMESTAMP(date_from,'yyyy.mm.ddhh24:mi');     
          rec_p.date_to     := TO_TIMESTAMP( date_to, 'yyyy.mm.ddhh24:mi');
          
         gmt_rec_p.date_from := FROM_TZ(SYS_EXTRACT_UTC (rec_p.date_from) , 'GMT');
         gmt_rec_p.date_to := FROM_TZ(SYS_EXTRACT_UTC (rec_p.date_to) , 'GMT');
         
     --   select TDF.ACCEPTED into ident from tm_doc_free_time tdf where  TDF.DATE_FROM = gmt_rec_p.date_from and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID; 
        
        select TDF.ACCEPTED into ident from tm_doc_free_time tdf where TO_CHAR(TDF.DATE_FROM,'yyyy.mm.ddhh24:mi') = TO_CHAR(rec_p.date_from,'yyyy.mm.ddhh24:mi') and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID; 
        
        if ident = 0 then
        
        delete from tm_doc_free_time tdf where  TO_CHAR(TDF.DATE_FROM,'yyyy.mm.ddhh24:mi') = TO_CHAR(rec_p.date_from,'yyyy.mm.ddhh24:mi')  and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID;    
        commit;
            
        end if;  
        
        if ident = 1 or ident = 2 then
          
           
           select TDF.PATIENT into mpatient from tm_doc_free_time tdf where  TO_CHAR(TDF.DATE_FROM,'yyyy.mm.ddhh24:mi') = TO_CHAR(rec_p.date_from,'yyyy.mm.ddhh24:mi')  and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID; 
           
           TM_MESSAGES_V2.SEND_MESSAGE(QBA_SYSTEM.G_USER_ID,mpatient,qba_lang.MESSAGE (p_name => 'SYS.PREJECT'),0);
           
           update tm_doc_free_time tdf set TDF.ACCEPTED = 0, TDF.PATIENT = null where TO_CHAR(TDF.DATE_FROM,'yyyy.mm.ddhh24:mi') = TO_CHAR(rec_p.date_from,'yyyy.mm.ddhh24:mi')  and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID;   
           
           commit;
           
        end if;
        
        concat_times;
         
   /*    delete from tm_doc_free_time tdf where  TO_CHAR(TDF.DATE_FROM,'yyyy.mm.ddhh24:mi') = TO_CHAR(rec_p.date_from,'yyyy.mm.ddhh24:mi')  and TDF.DOC_ID = QBA_SYSTEM.G_USER_ID;    
       commit; */
       
      --   qba_utils.redirect_url ( tm_common_v2.c#base_path||c#package || '.html'. , FALSE);
      qba_utils.redirect_url ( tm_common_v2.c#base_path || c#package || '.html' , FALSE);
          
          qba_utils.owa_cookie_send (name => 'light_message'
                              ,VALUE => qba_utils.escape_url (qba_lang.MESSAGE (p_name => 'SYS.ALL_CHANGES_SAVED'))
                              ,domain => qba_system.g_user_server_name
                              ,PATH => tm_common_v2.c#base_path
                              );
    sys.OWA_UTIL.http_header_close;
    
     end remove_event;
     
     
      PROCEDURE print_choose_calendar(doc_num in number)
      as
      rec QBA_USERS%ROWTYPE;
      rec2 tm_user_profile%ROWTYPE;
      begin
          IF qba_system.qba_engine_stopped THEN
               RETURN;
         END IF;
         
      
      d_doc := doc_num;   
      
      update tm_video_session tvs set TVS.LAS_VISIT = doc_num where TVS.SESSION_ID = 1; 
    
    TM_COMMON_V2.INIT;
    
     tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.VIDEO_CONFERENCES')
                             ,p_sub_title => qba_lang.MESSAGE (p_name => 'SYS.VIDEO_CONFERENCES') 
                             ,p_left_menu_num => 2
                             ,prc_callback => 'tm_videoconference_v2.header_callback'
                             );
                             
       HTP.p ('    <!-- Calendar -->');
--    HTP.p ('    <div id="div_diaryFullCalendar" style="display:none;">');
    HTP.p ('    <div id="div_diaryFullCalendar">');
    HTP.p ('      <div class="widget">');
    HTP.p ('        <div class="head"><h5 class="iDayCalendar">' || qba_lang.MESSAGE (p_name => 'SYS.EVENTS_CALENDAR') || '</h5></div>');
    HTP.p ('        <div id="diaryFullCalendar"></div>');
    HTP.p ('      </div>');
    HTP.p ('    </div>');
    
    SELECT * into rec FROM QBA_USERS qu where QU.USER_ID = doc_num; 
    SELECT * into rec2 from tm_user_profile tu where TU.USER_ID = doc_num;
    
/*    HTP.p('<div class="widget">');
    
    HTP.p('<br/>');
    HTP.p ('              <div class="rowElem noborder">');
    HTP.p ('                <label>' || qba_lang.MESSAGE (p_name => 'SYS.DOCTOR') || ':<span style="color:red;"></span></label>');
    HTP.p ('                <div class="formRight">');
    HTP.p ('                  <input type=text readonly value="' || HTF.escape_sc (rec.last_name) ||' '||HTF.escape_sc (rec.first_name)||' '||rec2.middle_name||' " name="u_last_name" class="validate[required]" id="u_last_name"/>');
    HTP.p ('                </div>');
    HTP.p ('              </div>');
    
    
    HTP.p ('              <div class="rowElem noborder">');
    HTP.p ('                <label>' || qba_lang.MESSAGE (p_name => 'SYS.phones') || ':<span style="color:red;"></span></label>');
    HTP.p ('                <div class="formRight">');
    HTP.p ('                  <input type=text readonly value="' || HTF.escape_sc (rec2.telephones) || '" name="u_first_name" class="validate[required]" id="u_first_name"/>');
    HTP.p ('                </div>');
    HTP.p ('                <div class="fix"></div>');
    HTP.p ('              </div>');
    
    
    
    HTP.p ('              <div class="rowElem noborder">');
    HTP.p ('                <label>' || qba_lang.MESSAGE (p_name => 'SYS.email') || ':<span style="color:red;"></span></label>');
    HTP.p ('                <div class="formRight">');
    HTP.p ('                  <input type=text readonly value="' || HTF.escape_sc (rec.email_address) || '" name="u_first_name" class="validate[required]" id="u_first_name"/>');
    HTP.p ('                </div>');
    HTP.p ('                <div class="fix"></div>');
    HTP.p ('              </div>');
    
    HTP.p('<div id="diaryFullCalendar"></div>');
    
    
    
    
  
    
    
  
 --   HTP.p('             <h3><a href ="#" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'')">Show calendar</a></h3>');
    
    HTP.p( '<a href="#" title="" onclick="$(''#div_diaryFullCalendar'').toggle();$(''#diaryFullCalendar'').fullCalendar(''render'');return false;">'
                                                                                                          || '<input type="button" value="'
                                                                                                          || qba_lang.MESSAGE (p_name => 'SYS.CHOOSE_DATE')
                                                                                                          || '" class="seaBtn" /></a>');
   
   HTP.p('</div>');
      
     */                       
                             
       tm_common_v2.page_footer;                      
                            
    
    
      end print_choose_calendar;
      
      
      procedure deleteOldEvents  as --tm_videoconference
 begin

  FOR rec IN (  SELECT *
                  FROM tm_doc_free_time tdf
              ORDER BY tdf.date_from  DESC) Loop

    IF rec.date_from < sysdate and rec.accepted <> 2  THEN
      delete from TM_DOC_FREE_TIME tdf where TDF.ID = rec.id;
    END IF;
  END LOOP;
  
  commit;

end deleteOldEvents;




      
      
      
       /* 
  procedure print_user_live_confs as 
  
  u_id NUMBER;
  begin
    
  
   IF tm_common_v2.c#user_profile.role_id IN (2, 3, 4, 5) AND tm_common_v2.c#patient_id IS NOT NULL THEN
      u_id   := tm_common_v2.c#patient_id;
    ELSE
      u_id   := qba_system.g_user_id;
    END IF;

    
    HTP.p ('            <table cellpadding="0" cellspacing="0" width="100%" class="tableStatic2" style="border: 1px solid #7cc9e3; border-top: none; ">');
    HTP.p ('              <thead>');
    HTP.p ('                <tr>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.THEME') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.DATE') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.TIME_START') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.STATUS') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.INITIATOR') || '</td>');
    HTP.p ('                </tr>');
    HTP.p ('              </thead>');
    HTP.p ('              <tbody>');
    
    for rec in (select t.id identificator, t.vc_theme,TO_CHAR(t.vc_date_from,'DD:MM') tt,TO_CHAR(t.vc_date_from,'HH:MM:SS') vv, vc_status,vc_initiator vc, us.user_id usid, ui.last_name lastn 
                from tm_videoconferences t, QBA_USERS us, tm_in_conference tic, QBA_USERS ui
                where t.vc_status <> '�����' and TIC.IN_VIDEOCONF = T.ID and  US.USER_ID = TM_COMMON_V2.C#USER_PROFILE.USER_ID and us.user_id = TIC.IN_USER and UI.USER_ID = T.VC_INITIATOR
                order by t.vc_date_from) loop
    
     HTP.p ('                <tr>');
     HTP.p ('            <td><a href="' || tm_common_v2.c#base_path || c#package || '.live_details?prid=' || rec.identificator || '">' || rec.vc_theme || '</a></td>');
     HTP.p ('                  <td>' || rec.tt || '</td>');
     HTP.p ('                  <td>' || rec.vv || '</td>');
     HTP.p ('                  <td>' || rec.vc_status || '</td>');
     HTP.p ('                  <td>' || rec.lastn || '</td>');
     HTP.p ('                </tr>');
     
     END LOOP;
 
       
    HTP.p ('              </tbody>');
    HTP.p ('            </table>');
   


  end print_user_live_confs;
  
  
  PROCEDURE print_user_archive_confs AS
  u_id NUMBER;
  rn NUMBER;

BEGIN
  IF tm_common_v2.c#user_profile.role_id IN (2, 3, 4, 5) AND tm_common_v2.c#patient_id IS NOT NULL THEN
      u_id   := tm_common_v2.c#patient_id;
    ELSE
      u_id   := qba_system.g_user_id;
    END IF;

  HTP.p ('            <table cellpadding="0" cellspacing="0" width="100%" class="tableStatic2" style="border: 1px solid #7cc9e3; border-top: none; ">');
    HTP.p ('              <thead>');
    HTP.p ('                <tr>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.THEME') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.DATE') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.TIME_START') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.STATUS') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.INITIATOR') || '</td>');
    HTP.p ('                </tr>');
    HTP.p ('              </thead>');
    HTP.p ('              <tbody>');
    
    
    rn:= 0;
    
    for rec in (select t.id identificator, t.vc_theme,TO_CHAR(t.vc_date_from,'DD:MM') tt,TO_CHAR(t.vc_date_from,'HH:MM:SS') vv, vc_status,vc_initiator vc, us.user_id usid, ui.last_name lastn 
                from tm_videoconferences t, QBA_USERS us, tm_in_conference tic, QBA_USERS ui
                where t.vc_status = '�����' and TIC.IN_VIDEOCONF = T.ID and  US.USER_ID = TM_COMMON_V2.C#USER_PROFILE.USER_ID and us.user_id = TIC.IN_USER and UI.USER_ID = T.VC_INITIATOR
                order by t.vc_date_from) LOOP
                
     rn := rn + 1;           

     HTP.p ('                <tr>');
     HTP.p ('            <td><a href="' || tm_common_v2.c#base_path || c#package || '.archive_details?prid=' || rec.identificator || '">' || rec.vc_theme || '</a></td>');
     HTP.p ('                  <td>' || rec.tt || '</td>');
     HTP.p ('                  <td>' || rec.vv || '</td>');
     HTP.p ('                  <td>' || rec.vc_status || '</td>');
     HTP.p ('                  <td>' || rec.lastn || '</td>');
     HTP.p ('                </tr>');
     
     END LOOP;
     
    
     
     
      IF rn = 0 THEN
      HTP.p ('                <tr>');
      HTP.p ('                  <td colspan="'|| rn ||'"> </td>');
      HTP.p ('                </tr>');
    END IF;
     
    
    
         
     HTP.p ('              </tbody>');
     HTP.p ('            </table>');
     
     
     
     
     
   

  END print_user_archive_confs;
 */ 
  
/*  
   PROCEDURE archive_details (prid IN NUMBER) AS
   rec_p    tm_videoconferences%ROWTYPE;
   user_p    QBA_USERS%ROWTYPE;
   speciality varchar2(30);
   rec_users       qba_users%ROWTYPE;
   ref_video       varchar2(256byte);
  BEGIN
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    tm_common_v2.init;
    
    tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.ARCHIVE_VIDEOCONF'), p_left_menu_num => 0, prc_callback => 'tm_prescription_v2.header_callback');
    
    HTP.p ('    <div class="widget first">');
    HTP.p ('      <form id="frm_archive_details" action="" method="post" class="mainForm">');
    HTP.p ('        <fieldset>');
    
    IF archive_details.prid IS NOT NULL THEN
     SELECT tt.*
       INTO rec_p
       FROM tm_videoconferences tt
      WHERE tt.id = archive_details.prid;
      end if;
      
    SELECT pp.* 
       INTO user_p
       FROM QBA_USERS pp
     WHERE PP.USER_ID = rec_p.vc_initiator;
     
     
    IF tm_common_v2.c#user_profile.role_id IN (2, 3, 4, 5) then
    speciality := qba_lang.MESSAGE(p_name => 'CLS.SPECIALIST');
    end if;
    
    IF tm_common_v2.c#user_profile.role_id = 6 then
    speciality := qba_lang.MESSAGE(p_name => 'CLS.PATIENT');
    end if;
    
     
     
      
    
    HTP.p('<div class="rowElem noborder" id = "noborder_theme" width: 260px>');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.INITIATOR') || '<span style="color:red;">*</span></label>');
    HTP.p('<div class="formRight">');
    HTP.p('<textarea>'||user_p.LAST_NAME||' '||user_p.FIRST_NAME||', '||speciality||'</textarea>');
    HTP.p('</div>');
    HTP.p('<div class="fix"></div>');
    HTP.p('</div>');
    
     
    HTP.p('<div class = "rowElem noborder">');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.ABONENT') ||'<span style="color:red;">*</span></label>');
    HTP.p('<div class = "formRight">');
  
     --Change select
     qba_utils.htp_form_select_option(cname_ => 'u_subscriber_id'
                                  ,cvalue_ => rec_users.user_id
                                  ,sql_text => 'select QU.LAST_NAME  as name from QBA_USERS qu, tm_in_conference tic
                                               where TIC.IN_VIDEOCONF = '||rec_p.id||' and TIC.IN_USER = QU.USER_ID and QU.USER_ID <> '||TM_COMMON_V2.C#USER_PROFILE.USER_ID||''
                                  ,cnull_ => TRUE
                                  ,cattributes_ => 'style="width: 292px');
    HTP.p('</div>');
    HTP.p('<div class = "fix"></div>');
    HTP.p('</div>');
    
    
    HTP.p('<div class="rowElem noborder" id = "noborder_theme">');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.THEME') || '<span style="color:red;">*</span></label>');
    HTP.p('<div class="formRight">');
    HTP.p('<textarea readonly = "readonly">'||rec_p.vc_theme||'</textarea>');
    HTP.p('</div>');
    HTP.p('<div class="fix"></div>');
    HTP.p('</div>');
    
    
    HTP.p('<div class="rowElem noborder" id = "noborder_comment">');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.COMMENT') || '</label>');
    HTP.p('<div class="formRight">');
    HTP.p('<textarea readonly="readonly">'||rec_p.vc_comment||'</textarea>');
    HTP.p('</div>');
    HTP.p('<div class="fix"></div>');
    HTP.p('</div>');
    
    HTP.p('<div class="rowElem noborder" id = "noborder_comment">');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.DATE_AND_TIME') || '</label>');
    HTP.p('<div class="formRight">');
    HTP.p('<label>'||TO_CHAR(rec_p.vc_date_from,'DD.MM')||'  '||TO_CHAR(rec_p.vc_date_from,'HH:MM')||'- '||TO_CHAR(rec_p.vc_date_to,'HH:MM')||'</label>');
    HTP.p('</div>');
    HTP.p('<div class="fix"></div>');
    HTP.p('</div>');
    
    HTP.p('<div class="rowElem noborder">');
    HTP.p('<div class="formRight">');
    HTP.p('</div>');
    HTP.p('</div>');
    HTP.p('<div class="widget" style="width: 685px; margin-left: 8px;">');
    HTP.p('<div class="head"><h5 class="iFrames">'||qba_lang.MESSAGE(p_name => 'SYS.ADD_PARTICIPANTS')||'</h5> </div>');
    HTP.p ('      <div class="tab_container">');
    HTP.p ('        <div id="tab1" class="tab_content">');
    HTP.p ('            <table cellpadding="0" cellspacing="0" width="100%" class="tableStatic2" style="border: 1px solid #7cc9e3; border-top: none; ">');
    HTP.p ('              <thead>');
    HTP.p ('                <tr>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.LAST_NAME') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.FIRST_NAME') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.MIDDLE_NAME') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.ROLE') || '</td>');
    HTP.p ('                </tr>');
    HTP.p ('              </thead>');
    HTP.p ('              <tbody>');
    
    for rec in (select QU.FIRST_NAME as firstname, QU.LAST_NAME as lastname, TR.ROLE_NAME as rol, UP.MIDDLE_NAME as middle  from qba_users qu, tm_in_conference ic, tm_roles tr, tm_user_profile up
                 where IC.IN_VIDEOCONF = rec_p.id and IC.IN_USER = QU.USER_ID and IC.IN_USER = UP.USER_ID and UP.ROLE_ID = TR.ROLE_ID) loop
                 
                 HTP.p ('                <tr>');
                 HTP.p ('                  <td>' || rec.lastname || '</td>');
                 HTP.p ('                  <td>' || rec.firstname || '</td>');
                 HTP.p ('                  <td>' || rec.middle || '</td>');
                 HTP.p ('                  <td>' || rec.rol || '</td>');
                 HTP.p ('                </tr>');
     
     END LOOP;
                  
     
     HTP.p ('              </tbody>');
     HTP.p ('            </table>');
     HTP.p('</div>');
     HTP.p('</div>');
     HTP.p('</div>');
     
     HTP.p('<div class="rowElem noborder">');
     HTP.p('<div class="formRight">');
     HTP.p('</div>');
     HTP.p('</div>');
     HTP.p('<div class="widget" style="width: 685px; margin-left: 8px;">');
     HTP.p('<div class="head"><h5 class="iFrames">'||qba_lang.MESSAGE(p_name => 'SYS.FILES')||'</h5> </div>');
     HTP.p ('      <div class="tab_container">');
     HTP.p ('        <div id="tab2" class="tab_content">');
     HTP.p ('            <table cellpadding="0" cellspacing="0" width="100%" class="tableStatic2" style="border: 1px solid #7cc9e3; border-top: none; ">');
     HTP.p ('              <thead>');
     HTP.p ('                <tr>');
     HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.DOC_NAME') || '</td>');
     HTP.p ('                  <td style = "width : 36px"></td>');
     HTP.p ('                </tr>');
     HTP.p ('              </thead>');
     HTP.p ('              <tbody>');
     
     for rec2 in (select T.DOC_NAME as name from tm_docs_in_conf  t where T.CONF = rec_p.id ) loop
     
                 HTP.p ('                <tr>');
                 HTP.p ('                  <td>' || rec2.name || '</td>');
                 HTP.p ('                  <td><a href="' || tm_common_v2.c#attach_doc_href || rec2.name || '"><img src="images/icons/middlenav/arrowDown.png" border="0" alt="" /></a></td>');
                 HTP.p ('                </tr>');
     
     
     end loop;
     HTP.p ('              </tbody>');
     HTP.p ('            </table>');
     HTP.p('</div>');
     HTP.p('</div>');
     HTP.p('</div>');
     
     select TS.REF_NAME into ref_video from tm_save_video ts where TS.ID_CONF = rec_p.id;
     
     HTP.p('<div class="rowElem noborder">');
     HTP.p('<div class="formRight">');
     HTP.p('</div>');
     HTP.p('</div>');
     HTP.p('<div class="widget" style="width: 680px; margin-left: 8px;">'); 
     HTP.p('                           <div class="head"><h5 class="iPencil">������ ����������������</h5></div>');
     HTP.p('                           <iframe width="680" height="328" src="http://www.youtube.com/embed/IrkxYEdsvSw" frameborder="0" allowfullscreen=""></iframe>');
     HTP.p('                          </div>');
                                
                                
                                
     
     HTP.p('<div class="rowElem noborder">');    
     HTP.p ('      <div class="rightbut">');
     HTP.p('         <a href="' || TM_COMMON_V2.C#VIDEO_CONF_HREF || '" title=""><input type="button" value="������" class="redBtn"/></a>');
     HTP.p('   </div>');
     HTP.p ('    </div>');
     HTP.p ( '                      </div>');                           
     
 
    
    
    
    
    
    
      
      
    
    
    HTP.p ('      </form>');
    HTP.p ('    </div>'); 
    
    
    tm_common_v2.page_footer;
    
    
  END archive_details;
  */
  
  --------------------------------
/*  PROCEDURE live_details (prid IN NUMBER) AS
   rec_p           tm_videoconferences%ROWTYPE;
   user_p          QBA_USERS%ROWTYPE;
   speciality      varchar2(30);
   rec_users       qba_users%ROWTYPE;
   ref_video       varchar2(256byte);
  BEGIN
    IF qba_system.qba_engine_stopped THEN
      RETURN;
    END IF;
    
    tm_common_v2.init;
    
    tm_common_v2.page_header (p_title => qba_lang.MESSAGE (p_name => 'SYS.VIDEOC'), p_left_menu_num => 0, prc_callback => 'tm_prescription_v2.header_callback');
    
    HTP.p ('    <div class="widget first">');
    HTP.p ('      <form id="frm_archive_details" action="" method="post" class="mainForm">');
    HTP.p ('        <fieldset>');
    
    IF live_details.prid IS NOT NULL THEN
     SELECT tt.*
       INTO rec_p
       FROM tm_videoconferences tt
      WHERE tt.id = live_details.prid;
      end if;
      
    SELECT pp.* 
       INTO user_p
       FROM QBA_USERS pp
     WHERE PP.USER_ID = rec_p.vc_initiator;
     
     
    IF tm_common_v2.c#user_profile.role_id IN (2, 3, 4, 5) then
    speciality := qba_lang.MESSAGE(p_name => 'CLS.SPECIALIST');
    end if;
    
    IF tm_common_v2.c#user_profile.role_id = 6 then
    speciality := qba_lang.MESSAGE(p_name => 'CLS.PATIENT');
    end if;
    
     
     
      
    
    HTP.p('<div class="rowElem noborder" id = "noborder_theme" width: 260px>');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.INITIATOR') || '<span style="color:red;">*</span></label>');
    HTP.p('<div class="formRight">');
    HTP.p('<textarea>'||user_p.LAST_NAME||' '||user_p.FIRST_NAME||', '||speciality||'</textarea>');
    HTP.p('</div>');
    HTP.p('<div class="fix"></div>');
    HTP.p('</div>');
    
     
    HTP.p('<div class = "rowElem noborder">');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.ABONENT') ||'<span style="color:red;">*</span></label>');
    HTP.p('<div class = "formRight">');
  
     --Change select
     qba_utils.htp_form_select_option(cname_ => 'u_subscriber_id'
                                  ,cvalue_ => rec_users.user_id
                                  ,sql_text => 'select QU.LAST_NAME as name from QBA_USERS qu, tm_in_conference tic
                                               where TIC.IN_VIDEOCONF = '||rec_p.id||' and TIC.IN_USER = QU.USER_ID and QU.USER_ID <> '||TM_COMMON_V2.C#USER_PROFILE.USER_ID||''
                                  ,cnull_ => TRUE
                                  ,cattributes_ => 'style="width: 292px');
    HTP.p('</div>');
    HTP.p('<div class = "fix"></div>');
    HTP.p('</div>');
    
    
    HTP.p('<div class="rowElem noborder" id = "noborder_theme">');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.THEME') || '<span style="color:red;">*</span></label>');
    HTP.p('<div class="formRight">');
    HTP.p('<textarea>'||rec_p.vc_theme||'</textarea>');
    HTP.p('</div>');
    HTP.p('<div class="fix"></div>');
    HTP.p('</div>');
    
    
    HTP.p('<div class="rowElem noborder" id = "noborder_comment">');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.COMMENT') || '</label>');
    HTP.p('<div class="formRight">');
    HTP.p('<textarea">'||rec_p.vc_comment||'</textarea>');
    HTP.p('</div>');
    HTP.p('<div class="fix"></div>');
    HTP.p('</div>');
    
    HTP.p ('              <div class="rowElem noborder" id = "noborder repeat">');
    HTP.p ('                <label style="width: 167px; margin-left: +0px;">'|| qba_lang.MESSAGE (p_name => 'SYS.REPEAT_EVERY_WEEK') || ':</label>');
    HTP.p ('                <div class="formRight">');
    HTP.p (  
         '                  <input type="checkbox" id="u_med_disability" name="u_med_disability" value="1" checked="checked" />');
    HTP.p('</div>');
    HTP.p('</div>');
    
    HTP.p('<div class="rowElem noborder" id = "noborder_comment">');
    HTP.p('<label>'||qba_lang.MESSAGE(p_name => 'SYS.DATE_AND_TIME') || '</label>');
    HTP.p('<div class="formRight">');
    HTP.p('<label>'||TO_CHAR(rec_p.vc_date_from,'DD.MM')||'  '||TO_CHAR(rec_p.vc_date_from,'HH:MM')||'- '||TO_CHAR(rec_p.vc_date_to,'HH:MM')||'</label>');
    HTP.p('</div>');
    HTP.p('<div class="fix"></div>');
    HTP.p('</div>');
    
    HTP.p('<div class="rowElem noborder">');
    HTP.p('<div class="formRight">');
    HTP.p('</div>');
    HTP.p('</div>');
    HTP.p('<div class="widget" style="width: 685px; margin-left: 8px;">');
    HTP.p('<div class="head"><h5 class="iFrames">'||qba_lang.MESSAGE(p_name => 'SYS.ADD_PARTICIPANTS')||'</h5> </div>');
    HTP.p ('      <div class="tab_container">');
    HTP.p ('        <div id="tab1" class="tab_content">');
    HTP.p ('            <table cellpadding="0" cellspacing="0" width="100%" class="tableStatic2" style="border: 1px solid #7cc9e3; border-top: none; ">');
    HTP.p ('              <thead>');
    HTP.p ('                <tr>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.LAST_NAME') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.FIRST_NAME') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.MIDDLE_NAME') || '</td>');
    HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.ROLE') || '</td>');
    HTP.p ('                </tr>');
    HTP.p ('              </thead>');
    HTP.p ('              <tbody>');
    
    for rec in (select QU.FIRST_NAME as firstname, QU.LAST_NAME as lastname, TR.ROLE_NAME as rol, UP.MIDDLE_NAME as middle  from qba_users qu, tm_in_conference ic, tm_roles tr, tm_user_profile up
                 where IC.IN_VIDEOCONF = rec_p.id and IC.IN_USER = QU.USER_ID and IC.IN_USER = UP.USER_ID and UP.ROLE_ID = TR.ROLE_ID) loop
                 
                 HTP.p ('                <tr>');
                 HTP.p ('                  <td>' || rec.lastname || '</td>');
                 HTP.p ('                  <td>' || rec.firstname || '</td>');
                 HTP.p ('                  <td>' || rec.middle || '</td>');
                 HTP.p ('                  <td>' || rec.rol || '</td>');
                 HTP.p ('                </tr>');
     
     END LOOP;
                  
     
     HTP.p ('              </tbody>');
     HTP.p ('            </table>');
     HTP.p('</div>');
     HTP.p('</div>');
     HTP.p('</div>');
     
     HTP.p('<div class="rowElem noborder">');
     HTP.p('<div class="formRight">');
     HTP.p('</div>');
     HTP.p('</div>');
     HTP.p('<div class="widget" style="width: 685px; margin-left: 8px;">');
     HTP.p('<div class="head"><h5 class="iFrames">'||qba_lang.MESSAGE(p_name => 'SYS.FILES')||'</h5> </div>');
     HTP.p ('      <div class="tab_container">');
     HTP.p ('        <div id="tab2" class="tab_content">');
     HTP.p ('            <table cellpadding="0" cellspacing="0" width="100%" class="tableStatic2" style="border: 1px solid #7cc9e3; border-top: none; ">');
     HTP.p ('              <thead>');
     HTP.p ('                <tr>');
     HTP.p ('                  <td>' || qba_lang.MESSAGE (p_name => 'SYS.DOC_NAME') || '</td>');
     HTP.p ('                  <td style = "width : 36px"></td>');
     HTP.p ('                </tr>');
     HTP.p ('              </thead>');
     HTP.p ('              <tbody>');
     
     for rec2 in (select T.DOC_NAME as name from tm_docs_in_conf  t where T.CONF = rec_p.id ) loop
     
                 HTP.p ('                <tr>');
                 HTP.p ('                  <td>' || rec2.name || '</td>');
                 HTP.p ('                  <td><a href="' || tm_common_v2.c#attach_doc_href || rec2.name || '"><img src="images/icons/middlenav/arrowUp.png" border="0" alt="" /></a></td>');
                 HTP.p ('                </tr>');
     
     
     end loop;
     HTP.p ('              </tbody>');
     HTP.p ('            </table>');
     HTP.p('</div>');
     HTP.p('</div>');
     HTP.p('</div>');
     
    
                                
                                
     HTP.p('<div class="rowElem noborder">');
     HTP.p('<div class="formRight">');
     HTP.p('</div>');
     HTP.p('</div>');
     HTP.p('<div class="rowElem noborder">');    
     HTP.p ('      <div class="rightbut">');
     HTP.p('         <a href="' || TM_COMMON_V2.C#VIDEO_CONF_HREF || '" title=""><input type="button" value="������" class="redBtn"/></a>');
     HTP.p('   </div>');
     HTP.p ('    </div>');
     HTP.p ( '                      </div>');                           
     
     
     HTP.p ('      </form>');
     HTP.p ('    </div>'); 
     
   --  HTP.p('</div>');
   --  HTP.p('</div>');
    
    
   -- tm_common_v2.page_footer; delete target in form
    
    
  END live_details;
  ---------------------------------
  */
     
     
     
  
  END tm_videoconference_v2;
/
