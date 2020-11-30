
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE proc [dbo].[p_CO_SAP_ObtenerIMAPConfiguracion]
as

	select conf.IdContratista,
			conf.ServidorIMAP,
			conf.Email,
			conf.Password,
			conf.Puerto,
			conf.CreadoEl,
			IdContrato = min(c.IdContrato)
	from [dbo].[CO_SAP_IMAPConfiguracion] conf
	inner join CO_Contrato c on c.IdCOntratista = conf.IdContratista
	where conf.idcontratista = 10014
	group by conf.IdContratista,
			conf.ServidorIMAP,
			conf.Email,
			conf.Password,
			conf.Puerto,
			conf.CreadoEl

