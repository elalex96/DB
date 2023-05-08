-- =============================================  
-- Author:  Daniel Cruz  
-- Create date: 23-03-17  
-- Description: Regresa el correo personalizado para DEA de notificación de cambio de estatus APROBADO     
-- =============================================  
 CREATE  PROCEDURE [dbo].[SP_DEA_PlantillaFacturaAprobadaProveedor]
 -- Add the parameters for the stored procedure here  
  @IdAceptacionPedido int      
AS  
BEGIN  
    
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
  DECLARE @RFC_ACTUAL NVARCHAR(200), @EXISTE_RFC INT;  
  DECLARE @PedidoId INT 
  
  /*OBTENER RFC DEL LA OPERADORA DE PROCURA*/
 set @EXISTE_RFC = (SELECT COUNT(DP.IdProveedor)
					FROM MM_AceptacionPedido AP
					JOIN MM_Pedido P
						ON AP.IdPedido = P.IdPedido
					JOIN S_Proveedor OPE
						ON P.IdProveedorCompras= OPE.IdProveedor
					JOIN DEA_Proveedor DP 
						ON  RTRIM(LTRIM(OPE.RFC))=RTRIM(LTRIM(DP.RFC))
						AND DP.Activo=1  
					WHERE AP.IdAceptacionPedido=@IdAceptacionPedido)  

					  
 IF ISNULL(@EXISTE_RFC,0)  >0   
 BEGIN   
  SELECT response = 'APLICA_CORREO_DEA',
		 html_correo = N'<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full">
   <tbody>
      <tr>
         <td height="25">&nbsp;</td>
      </tr>
   </tbody>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="full">
   <tbody>
      <tr>
         <td align="center">
            <table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
               <tbody>
                  <tr>
                     <td>
                        <table width="100%" bgcolor="#042444" cellspacing="0" cellpadding="0" align="center"                                      class="full" style="border-radius: 6px 6px 0 0;">
                           <tbody>
                              <tr>
                                 <td height="3"></td>
                              </tr>
                              <tr>
                                 <td>
                                    <table border="0" align="left" class="inner"                                                      style="border-collapse: collapse;">
                                       <tbody>
                                          <tr>
                                             <td height="45" class="inner" valign="middle"> <a> <img                                                                          style="padding-left:2em" class="logo"                                                                          src="https://procura.adinco.mx/assets/LogoADINCO.png"                                                                          width="75" height="75" alt="" /> </a> </td>
                                          </tr>
                                       </tbody>
                                    </table>
                                 </td>
                              </tr>
                              <tr>
                                 <td height="3"></td>
                              </tr>
                           </tbody>
                        </table>
                     </td>
                  </tr>
               </tbody>
            </table>
         </td>
      </tr>
   </tbody>
</table>
<!-- CUERPO DEL MENSAJE DE CORREO -->  
<table width="100%" cellspacing="0" cellpadding="0" align="center" class="full">
   <tbody>
      <tr>
         <td align="center">
            <table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
               <tbody>
                  <tr>
                     <td>
                        <table width="100%" bgcolor="#FFFFFF" border="0" cellspacing="0" cellpadding="0"                                      align="center" class="full"                                      style="background-repeat: repeat-x; background-position: left top;">
                           <tbody>
                              <tr>
                                 <td height="25">&nbsp;</td>
                              </tr>
                              <tr>
                                 <td align="center"                                                  style="font: 600 18px ''OPEN Sans'', Arial, Helvetica, sans-serif; color: black;"                                                  class="smallfont"> Estimado(a): ##NOMBRE_USUARIO##<br /> Dear:                                                  ##NOMBRE_USUARIO##<br /> </td>
                              </tr>
                              <tr>
                                 <td align="center"                                                  style="font: 200 14px ''OPEN Sans'', Arial, Helvetica, sans-serif; color:black;"                                                  class="smallfont"> <br /> La ##TIPO_OPERACION## No. ##NUMERO_OPERACION##                                                  <br /> The ##TIPO_OPERACION## No. ##NUMERO_OPERACION## <br /><br /> Área                                                  Contractual: ##AREA_CONTRACTUAL##<br /> Contractual Area:                                                  ##AREA_CONTRACTUAL## <br /><br /> Justificación: ##JUSTIFICACION##                                                  <br /> Justification: ##JUSTIFICACION## <br /><br /> </td>
                              </tr>
                              <tr>
                                 <td align="center"                                                  style="font: 600 14px ''OPEN Sans'', Arial, Helvetica, sans-serif; color:black;"                                                  class="smallfont"> Ha sido ##ESTATUS## <br /> has been ##STATUS## </td>
                              </tr>
                             <tr>
                               <td align="center" style="font: 200 14px ''OPEN Sans'', Arial, Helvetica, sans-serif; color:black;">
                                <br> A partir de este momento comienza el termino de pago de tu factura. Para las facturas con método de pago en parcialidades o diferido (PPD), te recordamos que una vez liquidada la factura debes emitir el complemento de pago y subirlo a PetroVendor, esto a más tardar el décimo día natural del mes siguiente al que se recibió el pago, en caso de no cumplir con esta obligación tus próximos pagos serán retenidos y no podrás ingresar nuevas facturas al sistema.
                               </td>
                             </tr>
                              <tr>
                                 <td height="16">&nbsp;</td>
                              </tr>
                              <tr>
                                 <td align="center"                                                  style="font: 600 12px ''OPEN Sans'', Arial, Helvetica, sans-serif; color: #042444;"                                                  class="smallfont"> Ingresa al portal, para ver el detalle <br /> Enter                                                  the portal, to see the detail <br /><br /><a href="##URL_TAREA##"                                                      name="btnDetalle" target="_blank"                                                      style="font-size: 12px;font-family: Helvetica, Arial, sans-serif;color: #ffffff;line-height: 10px;text-decoration: none;color: #ffffff;text-decoration: none;-webkit-border-radius: 5px;-moz-border-radius: 5px;border-radius: 5px;padding: 10px 10px;display: inline-block;letter-spacing: 1px;text-align: center;font-weight: bold;text-transform: uppercase;width: 16em;background: #2DB360">                                                      Ver Detalle<br />&nbsp;<br />See details</a> <br /> <br /> </td>
                              </tr>
                              <tr>
                                 <td height="10" style="text-align: center;">&nbsp;<em><span                                                          data-aspx-saved-src="[object Object]"                                                          style="font-size: 8pt;">&nbsp;Esta es una notificación                                                          automática de ADINCO, por favor no conteste este                                                          correo</span></em>&nbsp;</td>
                              </tr>
                           </tbody>
                        </table>
                     </td>
                  </tr>
               </tbody>
            </table>
         </td>
      </tr>
   </tbody>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="full">
   <tbody>
      <tr>
         <td align="center">
            <table width="600" border="0" cellspacing="0" cellpadding="0" align="center" class="devicewidth">
               <tbody>
                  <tr>
                     <td>
                        <table width="100%" bgcolor="#042444" cellspacing="0" cellpadding="0" align="center"                                      class="full" style="border-radius: 0 0 6px 6px;">
                           <tbody>
                              <tr>
                                 <td height="18"></td>
                              </tr>
                              <tr>
                                 <td>
                                    <table class="inner" align="center" width="230" border="0"                                                      cellspacing="0" cellpadding="0"                                                      style="border-collapse: collapse; text-align: center; ">
                                       <tbody>
                                          <tr>
                                             <td width="20">&nbsp;</td>
                                             <td>
                                                <table width="100%" border="0" cellspacing="0"                                                                      cellpadding="0" align="center">
                                                   <tbody>
                                                      <tr>
                                                         <td style="color: #FFFFFF;">| </td>
                                                         <td align="center"                                                                                  style="font: 10px Helvetica,  Arial, sans-serif; color: #FFFFFF;">                                                                                  © ##ANIO_ACTUAL##, Todos los derechos reservados                                                                              </td>
                                                         <td style="color: #FFFFFF;">| </td>
                                                      </tr>
                                                      <tr>
                                                         <td height="15">&nbsp;</td>
                                                      </tr>
                                                   </tbody>
                                                </table>
                                             </td>
                                             <td width="20">&nbsp;</td>
                                          </tr>
                                       </tbody>
                                    </table>
                                 </td>
                              </tr>
                           </tbody>
                        </table>
                     </td>
                  </tr>
               </tbody>
            </table>
         </td>
      </tr>
   </tbody>
</table>
<br />' 
 END   
 ELSE   
 BEGIN   
  SELECT response =  'NO_APLICA'
 END 
  
END  