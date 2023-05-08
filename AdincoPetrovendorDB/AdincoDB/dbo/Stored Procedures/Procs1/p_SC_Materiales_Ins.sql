CREATE proc p_SC_Materiales_Ins
(
	@pIdSubContrato		int,
	@pConcepto			varchar(max),
	@pIdUnidad			int,
	@pCantidad			decimal(14,5),
	@pPrecioUnitario	money,
	@pDescripcion		varchar(max),
	@pDescripcionCorta	varchar(max),
	@pIdUsuario			int,
	@pError				varchar(250) out
)
as
begin

	declare @pIdSCMaterial		int,
		@idBitacora int

	select @pIdSCMaterial = isnull(max(IdSCMaterial),0)+1 from SC_Materiales

	begin try

		begin tran

			insert into SC_Materiales 
						(
							IdSCMaterial,
							Concepto,
							IdUnidad,
							Cantidad,
							PrecioUnitario,
							Descripcion,
							DescripcionCorta,
							IdSubContrato,
							IdMaestro,
							Importe,
							CreadoPor,
							CreadoEl
						)
					values
						(
							@pIdSCMaterial,
							@pConcepto,
							@pIdUnidad,
							@pCantidad,
							@pPrecioUnitario,
							@pDescripcion,
							@pDescripcionCorta,
							@pIdSubContrato,
							null,
							@pCantidad*@pPrecioUnitario,
							@pIdUsuario,
							GETDATE()
						)
		

			select @idBitacora = isnull(max(IdSCBitacora),0)+1
			from SC_MaterialesBitacora

			insert into SC_MaterialesBitacora(IdSCBitacora,IdSCMaterial,CantidadRespaldo,FechaRespaldo,ModificadoPor,Cantidad,PrecioUnitario)
			select @idBitacora,@pIdSCMaterial,@pCantidad,getdate(),@pIdUsuario,@pCantidad,@pPrecioUnitario

			EXEC [dbo].[p_SC_Materiales_Gen] @pIdSubContrato,''

		commit tran
	end try
	begin catch
		rollback tran
		set @pError = 'Ocurrió un error inesperado'+ERROR_MESSAGE()
	end catch
end
