create PROCEDURE [dbo].[SP_Correo_ConsultarServidorCorreo]
as
begin
 SELECT IdServidor,'Servidor: '+CAST(ISNULL(IdServidor,0) AS NVARCHAR(300)) +' '+ISNULL(CuentaRegistro,'SMTP No Disponible') +' - SMPT:' + ISNULL(SMTP,'SMTP No Disponible')+' - Puerto:'+ CAST(ISNULL(Puerto,0) AS NVARCHAR(300)) AS CuentaRegistro
	   FROM MA_ServidorDeCorreo
	 
end