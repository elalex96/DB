
-- p_CO_SAP_ImportBitacoraNotificacion 355,0
create proc p_CO_SAP_ImportBitacoraNotificacion
@pId int,
@pIdNotificacion int out
as

	--S_Notificacion
	declare 
		
		@para varchar(500)='',
	
		@asunto varchar(250),
		@mensaje varchar(max)='
			<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="http://fonts.googleapis.com/css?family=Open+Sans:400,300,700,600" rel="stylesheet" type="text/css">
    <title>kreative</title>
    <style type="text/css">
        div, p, a, li, td {
            -webkit-text-size-adjust: none;
        }

        .ReadMsgBody {
            width: 100%;
            background-color: #d1d1d1;
        }

        .ExternalClass {
            width: 100%;
            background-color: #d1d1d1;
            line-height: 100%;
        }

        body {
            width: 100%;
            height: 100%;
            background-color: #d1d1d1;
            margin: 0;
            padding: 0;
            -webkit-font-smoothing: antialiased;
            -webkit-text-size-adjust: 100%;
        }

        html {
            width: 100%;
        }

        img {
            -ms-interpolation-mode: bicubic;
        }

        table[class=full] {
            padding: 0 !important;
            border: none !important;
        }

        table td img[class=imgresponsive] {
            width: 100% !important;
            height: auto !important;
            display: block !important;
        }

        @media only screen and (max-width: 800px) {
            body {
                width: auto !important;
            }

            table[class=full] {
                width: 100% !important;
            }

            table[class=devicewidth] {
                width: 100% !important;
                padding-left: 20px !important;
                padding-right: 20px !important;
            }

            table td img.responsiveimg {
                width: 100% !important;
                height: auto !important;
                display: block !important;
            }
        }

        @media only screen and (max-width: 640px) {
            table[class=devicewidth] {
                width: 100% !important;
            }

            table[class=inner] {
                width: 100% !important;
                text-align: center !important;
                clear: both;
            }

            table td a[class=top-button] {
                width: 160px !important;
                font-size: 14px !important;
                line-height: 37px !important;
            }

            table td[class=readmore-button] {
                text-align: center !important;
            }

                table td[class=readmore-button] a {
                    float: none !important;
                    display: inline-block !important;
                }

            .hide {
                display: none !important;
            }

            table td[class=smallfont] {
                border: none !important;
                font-size: 26px !important;
            }

            table td[class=sidespace] {
                width: 10px !important;
            }
        }

        @media only screen and (max-width: 520px) {
        }

        @media only screen and (max-width: 480px) {
            table {
                border-collapse: collapse;
            }

                table td[class=template-img] img {
                    width: 100% !important;
                    display: block !important;
                }
        }

        @media only screen and (max-width: 320px) {
        }
    </style>
</head>
<body>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full">
        <tr>
            <td height="50">&nbsp;</td>
        </tr>
</table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full">
        <tr>
            <td align="center">
                <table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
                    <tr>
                        <td>
                            <table width="100%" bgcolor="#ffffff" border="0" cellspacing="0" cellpadding="0" align="center" class="full" style="border-radius:7px 7px 0 0;">
                                <tr>
                                    <td style="padding-left:1em; padding-bottom:.5em; padding-top:.5em">
                                        <table border="0" cellspacing="0" cellpadding="0" align="left" class="inner" style="border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt;">
                                            <tr>
                                                <td height="75" class="inner" valign="middle"><a href="#"><img editable class="logo" src="https://media.licdn.com/mpr/mpr/shrinknp_200_200/AAEAAQAAAAAAAAnCAAAAJDI0ZTYyZjNkLTNiZGUtNDE5Mi05ZmU5LTI2N2MxZWZkM2Fm




OA.jpg" width="80" height="80" label="Logo"></a></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="full">
        <tr>
            <td align="center">
                <table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
                    <tr>
                        <td>
                            <table width="100%" bgcolor="#585858" border="0" cellspacing="0" cellpadding="0" align="center" class="full" style="background-image:url(images/white-bg.gif); background-repeat:repeat-x; background-position:left top;">
                        </td>
                    </tr>
                    <tr>
                        <td height="20">&nbsp;</td>
                    </tr>
                    <tr>
                        <td align="center" style="font:300 27px "Open Sans", Arial, Helvetica, sans-serif; color:#16c4a9;" class="smallfont">
                            <singleline>
                                {0}
                            </singleline>
                        </td>
                    </tr>
                    <tr>
                        <td height="16">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
                                <tr>
                                    <td width="30%" height="2"></td>
                                    <td width="10%" style="border-bottom:1.5px solid #ffffff"></td>
                                    <td width="30%" height="2"></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="16">&nbsp;</td>
                    </tr>
                    <tr>
                        <td align="center" style="font:700 27px "Open Sans", Arial, Helvetica, sans-serif; color:#FFFFFF;" class="smallfont">
                            <singleline>
                                {1}
								<br>
								{2}
                            </singleline>
                        </td>
                    </tr>
                    <tr>
                        <td height="10">&nbsp;</td>
                    </tr>
                    <tr>
                        <td height="10">&nbsp;</td>
                    </tr>
                    
 <tr>
                        <td height="20">&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full">
        <tr>
            <td align="center">
                <table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
                    <tr>
                        <td>
                            <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0" align="center" class="full" style="border-radius:0 0 7px 7px;">
                                <tr>
                                    <td>
                                        <table class="inner" align="left" width="230" border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt; text-align:center;">
                                            <tr>
                                                <td width="20">&nbsp;</td>
                                                <td style="padding-bottom:1em;padding-top:1em">
                                                    <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center">
                                                        <tr>
                                                            <td align="center" style="font:11px Helvetica,  Arial, sans-serif; color:#000000;"><singleline>&copy; 2017, Todos los derechos reservados</singleline> </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td width="20">&nbsp;</td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>',
		@de varchar(100) = '',
		@mensajeDetalle  varchar(max)=''


	select @para = @para + isnull(Correo,'') + ';',
		@asunto = 'SAP-ADINCO Import  - Results of executions ' + convert(varchar,Inicio,107) + ' ' +convert(varchar,Inicio,108),
		@de = cs.CuentaRegistro
	from [dbo].[CO_SAP_ImportBitacora] b
	inner join CO_Contrato c on c.IdContrato = b.IdContrato
	inner join [dbo].[CO_SAP_CorreosRespuesta] res on res.IdContratista = c.IdContratista
	inner join [S_CorreoServidor] cs on cs.IdCorreoServidor = 1
	where Id = @pId

	

	if len(isnull(@para,'')) = 0
		return

	select @mensaje = replace(@mensaje,'{0}',
	'<B>RESULT OF IMPORTATION SAP FILES</B><BR><BR>'+
	'CONTRACT:' + '<b>'+c.NumeroContrato+'</b><br>'+
	'START:' +'<b>'+ convert(varchar,Inicio,107) + ' ' +convert(varchar,Inicio,108)+'</b><br>'+
	'END:' +'<b>'+ convert(varchar,Fin,107) + ' ' +convert(varchar,Fin,108)+'</b><br><br>'+
	case when b.TieneError = 1 then '<p style="color:red">It ended with errors</p><br><br>' else '' end)
	from [dbo].[CO_SAP_ImportBitacora] b
	inner join CO_Contrato c on c.IdContrato = b.IdContrato
	inner join [dbo].[CO_SAP_CorreosRespuesta] res on res.IdContratista = c.IdContratista
	where Id = @pId

	set @mensajeDetalle = '<table class="table"><tr><td><b>Step</b></td><td><b>Result</b></td></tr>'

	select @mensajeDetalle = @mensajeDetalle +'<tr><td>'+bd.NombreArchivo+'</td>'+
							  '<td>'+case when bd.TieneError = 1 then '<p style="color:red">'+bd.Error+'</p><br><br>'
										 else '<p style="color:gren">OK</p><br><br>'
									End+'</td></tr>'
	from [dbo].[CO_SAP_ImportBitacora] b
	inner join CO_SAP_ImportBitacora_Detalle bd on bd.IdIMportBitacora = b.Id
	where b.Id = @pId

	set @mensajeDetalle = @mensajeDetalle + '</table>'

	set @mensaje = replace(@mensaje,'{1}',@mensajeDetalle)


	/***************Obtener vendors sin TAXID**************************/

	select v.VendorIDSAP,
		v.VendorName
	into #tmpVendorBlank
	from [CO_SAP_ImportBitacora] ib
	inner join CO_SAPVendor  v on v.IdContrato = ib.IdContrato and
							rtrim(isnull(v.TaxID,'')) = ''
	where Id = @pId 
	group by v.VendorIDSAP,
		v.VendorName


	if exists(	
		select 1
		from #tmpVendorBlank
	)
	begin
	
		set @mensajeDetalle = '<p style="color:red;">There are Vendors without TAXID</p><br>'
		set @mensajeDetalle = @mensajeDetalle + '<table class="table"><tr><td><b>VendorID</b></td><td><b>Vendor Name</b></td></tr>'

		select @mensajeDetalle = @mensajeDetalle +'<tr><td>'+ cast(VendorIDSAP as varchar)+'</td>'+
							  '<td>'+VendorName+'</td></tr>'
		from #tmpVendorBlank

		set @mensajeDetalle = @mensajeDetalle + '</table>'

		set @mensaje = replace(@mensaje,'{2}',@mensajeDetalle)


	end
	Else
	Begin
		set @mensaje = replace(@mensaje,'{2}','')
	End

	select @pIdNotificacion = isnull(max(IdNotificacion),0) + 1
	from S_Notificacion

	insert into S_Notificacion(
		IdNotificacion,Para,Asunto,Mensaje,FechaProgramadaEnvio,Enviada,FechaEnvio,
		CreadoPor,CreadoEl,ModificadoPor,ModificadoEl,De,EN_MsjEnviado
	)
	select @pIdNotificacion ,@para,@asunto,isnull(@mensaje,''),dateadd(HOUR,-3,getdate()),0,null,
	1,getdate(),null,null,@de,null
	





