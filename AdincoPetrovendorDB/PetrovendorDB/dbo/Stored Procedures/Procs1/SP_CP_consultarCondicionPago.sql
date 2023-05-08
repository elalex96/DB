
create PROCEDURE [dbo].[SP_CP_consultarCondicionPago]
	@idContratistaSubContratista int
AS
BEGIN
     select IdCondicionPago, Contado, Credito, Anticipo, DiasCredito, PorcentajeAnticipo
		from PV_CondicionesPago
		where IdContratistaSubContratista = @idContratistaSubContratista
	 	 
END


--select * from PV_ContratistaSubContratista
--select * from pv_condicionesPago
