--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE proc p_SC_Materiales_Upd
(
    @pIdSCMaterial      int,
    @pConcepto          varchar(max),
    @pIdUnidad          int,
    @pCantidad          decimal(14,5),
    @pPrecioUnitario    money,
    @pDescripcion       varchar(max),
    @pDescripcionCorta  varchar(max),
	@pModificadoPor int,
	@pError				varchar(250) out
)
as
begin

	declare @IdSubcontrato int,
	@idBitacora int

	select @IdSubcontrato = IdSubContrato
	from SC_Materiales
	where IdSCMaterial = @pIdSCMaterial

	

	 if exists (
        select 1
        from OT_Solicitud 
        where IdSubcontrato = @IdSubcontrato and
        isactivo = 1 and
        IDOTEstatus = 9
    )
    begin
		set @pError = '[ALERTA] Hay CONVENIOS pendientes de aprobar para este contrato,no es posible actualizar esta partida. Es necesario  ir a PROCURA a la sección de convenios para subcontratos';         
        return  
    end

	begin try

		begin tran

		update  SC_Materiales
		set     Concepto        =   @pConcepto,
				IdUnidad        =   @pIdUnidad,
				Cantidad        =   @pCantidad
,
				PrecioUnitario  =   @pPrecioUnitario,
				Importe         =   @pPrecioUnitario * @pCantidad,
				Descripcion = @pDescripcion,
				DescripcionCorta = @pDescripcionCorta
		where   IdSCMaterial    =   @pIdSCMaterial

		select @idBitacora = isnull(max(IdSCBitacora),0)+1
		from SC_MaterialesBitacora

		insert into SC_MaterialesBitacora(IdSCBitacora,IdSCMaterial,CantidadRespaldo,FechaRespaldo,ModificadoPor,Cantidad,PrecioUnitario)
		select @idBitacora,@pIdSCMaterial,@pCantidad,getdate(),@pModificadoPor,@pCantidad,@pPrecioUnitario


		

		commit tran
	end try
	begin catch
		rollback tran
		set @pError = 'Ocurrió un error inesperado'   
	end catch
end

