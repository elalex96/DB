-- =============================================
-- Author:	Daniel Ac
-- Create date: 13/04/2018
-- Description:	Agregar un detalle del material que se utilizar pa CPCN
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_AgregarMaterialesUtilizados]

@IdRelacionValorPedidoDetalle int,
@ValorFactura DECIMAL(18,4),
@ProporcionCN DECIMAL(18,4),
@CreadoPor int, 
@Descripcion nvarchar(max),
@IdTipo int, 
@Proveedor nvarchar(max),
@RFC nvarchar(max),
@IdPCNProveedor NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @RFC = (SELECT RFC FROM dbo.MM_PCN_Proveedor WHERE IdPCNProveedor=@IdPCNProveedor)
	SET @Proveedor = (SELECT RazonSocial FROM dbo.MM_PCN_Proveedor WHERE IdPCNProveedor=@IdPCNProveedor)
	
	INSERT INTO [dbo].[MM_PCN_MaterialesUtilizados](
	[IdValoresEnPesosPedidoDetalle],
	[Descripcion],
	[VM_ValorFactura],
	[PCNM_Utilizado],
	[CreadoPor],
	[CreadoEl],
	[IdTipoMaterial],
	[NombreProveedor],
	[RFC],
	[IdPCNProveedor])
	VALUES(
	@IdRelacionValorPedidoDetalle,
	@Descripcion,
	@ValorFactura,
	@ProporcionCN,
	@CreadoPor,
	GETDATE(),
	@IdTipo,
	ISNULL(@Proveedor,''),
	ISNULL(@RFC,''),
	@IdPCNProveedor
	)


	SELECT @@IDENTITY  AS IdMaterialServicioUtilizado
END


