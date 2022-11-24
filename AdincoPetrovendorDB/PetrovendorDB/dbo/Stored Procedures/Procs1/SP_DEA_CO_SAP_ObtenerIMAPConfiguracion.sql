-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/09/2019
-- Description:	
-- =============================================
CREATE PROC [dbo].[SP_DEA_CO_SAP_ObtenerIMAPConfiguracion]
as
begin
	select conf.IdServidorIMAP,
			conf.ServidorIMAP,
			conf.Email,
			conf.Password,
			conf.Puerto,
			conf.CreadoEl
	from [dbo].[CO_SAP_IMAPConfiguracion] conf
	group by conf.IdServidorIMAP,
			conf.ServidorIMAP,
			conf.Email,
			conf.Password,
			conf.Puerto,
			conf.CreadoEl
end