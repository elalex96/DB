-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/09/2019
-- Description:	
-- =============================================
CREATE PROC [dbo].[SP_DEA_CO_SAP_ObtenerIMAPConfiguracion]
as

	--select conf.IdServidorIMAP,
	--		conf.ServidorIMAP,
	--		conf.Email,
	--		conf.Password,
	--		conf.Puerto,
	--		conf.CreadoEl
	--from [dbo].[CO_SAP_IMAPConfiguracion] conf
	--group by conf.IdServidorIMAP,
	--		conf.ServidorIMAP,
	--		conf.Email,
	--		conf.Password,
	--		conf.Puerto,
	--		conf.CreadoEl

	--select conf.IdServidorIMAP,
	--		conf.ServidorIMAP,
	--		'alexander.gomez@adinco.mx'AS Email,
	--		'Memoria11' AS Password,
	--		conf.Puerto,
	--		conf.CreadoEl
	--from [dbo].[CO_SAP_IMAPConfiguracion] conf
	--group by conf.IdServidorIMAP,
	--		conf.ServidorIMAP,
	--		conf.Email,
	--		conf.Password,
	--		conf.Puerto,
	--		conf.CreadoEl

	select conf.IdServidorIMAP,
			conf.ServidorIMAP,
			'wdeaPOPDF@outlook.com'AS Email,
			'Adinco2023#' AS Password,
			conf.Puerto,
			conf.CreadoEl
	from [dbo].[CO_SAP_IMAPConfiguracion] conf
	group by conf.IdServidorIMAP,
			conf.ServidorIMAP,
			conf.Email,
			conf.Password,
			conf.Puerto,
			conf.CreadoEl