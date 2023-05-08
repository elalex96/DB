-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DocumentoAprobacionCuentaBancaria]
@IdCuentaBancaria int,
@IdSubContratista int,
@IdTipoOperacion int
AS
declare @DocumentoExistente int
BEGIN


	SET NOCOUNT ON;

	if @IdTipoOperacion = 11 --Verificar estatus aprobación Cuentas propias del proveedor
	begin	
	set @DocumentoExistente = (
	select count(*) from [dbo].[PV_DocumentoCuentaBancaria] where [IdCuentaBancaria] = @IdCuentaBancaria
	and EstatusAprobacion = 2 and IsActivo = 1 and IdTipoOperacion = @IdTipoOperacion)

	if @DocumentoExistente > 0 
	begin
	select 'documento cargado' as response
	end
	else
	begin

	select 'Sin documento' as response

	end
	end

	if @IdTipoOperacion = 12 --Verificar estatus aprobación asociación cuenta/subcontratista
	begin
	set @DocumentoExistente = (
	select count(*) from [dbo].[PV_DocumentoCuentaBancaria] where [IdCuentaBancaria] = @IdCuentaBancaria
	and IdSubContratista = @IdSubContratista
	and EstatusAprobacion = 2 and IsActivo = 1 and IdTipoOperacion = @IdTipoOperacion)

	if @DocumentoExistente > 0 
	begin
	select 'documento cargado' as response
	end
	else
	begin

	select 'Sin documento' as response

	end
	end

	if @IdTipoOperacion = 13 --Verificar estatus aprobación eliminar asociación cuenta/subcontratista
	begin 
	set @DocumentoExistente = (
	select count(*) from [dbo].[PV_DocumentoCuentaBancaria] where [IdCuentaBancaria] = @IdCuentaBancaria
	and IdSubContratista = @IdSubContratista
	and EstatusAprobacion = 2 and IsActivo = 1 and IdTipoOperacion = @IdTipoOperacion)

	if @DocumentoExistente > 0 
	begin
	select 'documento cargado' as response
	end
	else
	begin

	select 'Sin documento' as response

	end
	end


END

