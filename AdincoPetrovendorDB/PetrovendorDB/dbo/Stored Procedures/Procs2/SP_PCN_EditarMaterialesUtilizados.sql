-- =============================================
-- Author:	Daniel Ac
-- Create date: 13/04/2018
-- Description:	Editar un detalle del material que se utilizar pa CPCN
-- =============================================
CREATE PROCEDURE [dbo].[SP_PCN_EditarMaterialesUtilizados]

@IdRelacionValorPedidoDetalle int,
@IdMaterialServicioUtilizado int,
@ValorFactura decimal(18,4),
@ProporcionCN decimal(18,4),
@CreadoPor int, 
@Descripcion nvarchar(max),
@IdTipo int, 
@Proveedor nvarchar(max),
@RFC nvarchar(max),
@IdPCNProveedor INT 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SET @RFC = (SELECT RFC FROM dbo.MM_PCN_Proveedor WHERE IdPCNProveedor=@IdPCNProveedor)
	SET @Proveedor = (SELECT RazonSocial FROM dbo.MM_PCN_Proveedor WHERE IdPCNProveedor=@IdPCNProveedor)

	UPDATE MM_PCN_MaterialesUtilizados
	SET [Descripcion] =@Descripcion ,
	[VM_ValorFactura]=@ValorFactura,
	[PCNM_Utilizado]=@ProporcionCN,
	[CreadoPor]=@CreadoPor,
	[CreadoEl]=GETDATE(),
	[IdTipoMaterial]=@IdTipo,
	[NombreProveedor]=ISNULL(@Proveedor,''),
	[RFC]=ISNULL(@RFC,''),
	[IdPCNProveedor]=@IdPCNProveedor
	WHERE [IdMaterialServicioUtilizado]=@IdMaterialServicioUtilizado
	  
END


