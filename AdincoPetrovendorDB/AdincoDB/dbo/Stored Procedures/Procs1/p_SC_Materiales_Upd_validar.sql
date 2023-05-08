create proc p_SC_Materiales_Upd_validar
@pIdSubcontrato int,
@pIdSCMaterial int,
@pCantidad decimal(14,5),
@pError varchar(250) out
as

BEGIN TRY

	set @pError = ''
	declare @cantidadOT decimal(14,5)=0  

	--Validar convenio
	if exists (
		select 1
		from OT_Solicitud 
		where IdSubcontrato = @pIdSubcontrato and
		isactivo = 1 and
		IDOTEstatus = 9
	)
	begin
		set @pError = 'Hay convenios pendientes para este contrato, no es posible actualizar esta partida. Es necesario  ir a PROCURA a la sección de convenios para subcontratos'
		return	
	end

	select @cantidadOT = dbo.fn_SC_GetCantidadUsada(@pIdSCMaterial)

	if(@pCantidad  < isnull(@cantidadOT,0)  )
	begin
		set @pError = 'Las OT relacionadas a este servicio necesitan un mínimo de ' + CAST(isnull(@cantidadOT,0) AS VARCHAR)
		return
	end

     
END TRY  
BEGIN CATCH  

	set @pError = error_message()
    
END CATCH  
