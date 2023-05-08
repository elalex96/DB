
create PROCEDURE [db_owner].[SP_DG_guardarCondicionesPago]
	@contado bit,
	@credito bit,
	@anticipo bit,
	@diasCredito int,
	@porcentajeAnticipo int,
	@idContratistaSubContratista int
AS
BEGIN
     declare @contadaor int
	 set @contadaor = (select count(IdCondicionPago) from PV_CondicionesPago 
						where IdContratistaSubContratista = @idContratistaSubContratista)

	 if(@contadaor > 0)
	 begin
		update PV_CondicionesPago
		set Contado = @contado,
			Credito = @credito,
			Anticipo = @Anticipo,
			DiasCredito = @diasCredito,
			PorcentajeAnticipo = @porcentajeAnticipo
		where IdContratistaSubContratista = @idContratistaSubContratista
	 end
	 else
	 begin
		insert into PV_CondicionesPago(IdContratistaSubContratista, Contado, Credito, Anticipo, DiasCredito, PorcentajeAnticipo)
		values (@idContratistaSubContratista, @contado, @credito, @anticipo, @diasCredito, @porcentajeAnticipo)
	 end
	 	 
END


--select * from PV_ContratistaSubContratista
--select * from pv_condicionesPago
