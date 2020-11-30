-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PCN_AgregarMaterialEncabezado]

@IdRelacionValorPedidoDetalle int,
@VM_ValorFactura float,
@PCNM_Utilizado float,
@CreadoPor int, 
@Descripcion nvarchar(max),
@IdTipoMaterial int, 
@Proveedor nvarchar(max),
@RFC nvarchar(max)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[MM_PCN_MaterialesUtilizados](
	[IdValoresEnPesosPedidoDetalle],
	[Descripcion],
	[VM_ValorFactura],
	[PCNM_Utilizado],
	[CreadoPor],
	[CreadoEl],
	[IdTipoMaterial],
	[NombreProveedor],
	[RFC])
	VALUES(
	@IdRelacionValorPedidoDetalle,
	@Descripcion,
	@VM_ValorFactura,
	@PCNM_Utilizado,
	@CreadoPor,
	GETDATE(),
	@IdTipoMaterial,
	@Proveedor,
	@RFC
	)


	SELECT @@IDENTITY  AS IdMaterialServicioUtilizado
END

