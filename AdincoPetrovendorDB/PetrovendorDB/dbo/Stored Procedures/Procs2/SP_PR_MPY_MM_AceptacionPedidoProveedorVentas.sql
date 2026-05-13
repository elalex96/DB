-- =============================================
-- Author:		Daniel Cruz
-- Update date: 23-03-2018
-- Description:	No mostrar aceptaciones de pedido de nacionalidad extranjera ya su proceso no requiere aprobación de carta de contenido nacional
-- Author:		Daniel Cruz
-- Update date: 31-05-2018
-- Description:	Actualizar consultas para ocultar aprobaciones de carta de contenido nacional eliminadas con el pedido, aceptacion, o solicitud  de pedido
-- =============================================
CREATE procedure [dbo].[SP_PR_MPY_MM_AceptacionPedidoProveedorVentas]
	-- Add the parameters for the stored procedure here
@IdProveedor NVARCHAR(20),
@Estatus INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF @Estatus=0
	BEGIN
         SELECT 
			A.IdAceptacionPedido,
			A.IdPedido,
			A.Creado,
			ISNULL(ISNULL(CONCAT(PV.RazonSocial ,' ', ISNULL(PV.RegimenCapital,'')),A.IdProveedor),A.VendorsName) AS Cliente,
			AC.IdAceptacionCartaPCN
         FROM dbo.MPY_MM_AceptacionPedido AS A		 
		 LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido	AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1
		 LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus
		 LEFT JOIN dbo.S_Proveedor AS PV ON PV.RFC = A.IdProveedor AND PV.Activo = 1
         WHERE A.IdSubContratista = @IdProveedor 
		 AND AC.IdAceptacionCartaPCN IS NULL
		 GROUP BY 
		 A.IdAceptacionPedido,
		 A.IdPedido,
		 A.Creado,
		 A.NombreUsuarioEntrega,
		 PV.RazonSocial,
		 PV.RegimenCapital,
		 A.IdProveedor,
		 AC.IdAceptacionCartaPCN,
		 A.VendorsName
		 ORDER BY A.IdAceptacionPedido DESC
       END   


	IF @Estatus IN (1,2,3)
	BEGIN

		SELECT 
			A.IdAceptacionPedido,
			A.IdPedido,
			A.Creado,
			ISNULL(ISNULL(CONCAT(PV.RazonSocial ,' ', ISNULL(PV.RegimenCapital,'')),A.IdProveedor),A.VendorsName) AS Cliente,
			AC.IdAceptacionCartaPCN,
			ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') AS EstatusAprobacion
         FROM dbo.MPY_MM_AceptacionPedido AS A		 
		 LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido	AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1
		 LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus
		 LEFT JOIN dbo.S_Proveedor AS PV ON PV.RFC = A.IdProveedor AND PV.Activo = 1
         WHERE A.IdSubcontratista = @IdProveedor
		 AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO 
		 AND ISNULL(AC.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACION CARTA CN
		 AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN 
										  FROM dbo.MPY_MM_AceptacionCartaPCN A_PCN 
										  WHERE A_PCN.IdAceptacionPedido=A.IdAceptacionPedido 
										  ORDER BY A_PCN.CreadoEl DESC) 			  
		 ) AND AC.IdEstatus =@Estatus AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA
		 GROUP BY 		
		 A.IdAceptacionPedido,
		 A.IdPedido,
		 A.Creado,
		 A.NombreUsuarioEntrega,
		 PV.RazonSocial,
		 PV.RegimenCapital,
		 A.IdProveedor,
		 AC.IdAceptacionCartaPCN,
		 TV.TipoValidacion,
		 A.VendorsName
		 ORDER BY A.IdAceptacionPedido DESC
		 
       END  

	IF @Estatus =4
	BEGIN
	  
		-- MOSTRAR TODOS LOS ULTIMOS ESTATUS DE LA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL		
		SELECT 
			A.IdAceptacionPedido,
			A.IdPedido,
			A.Creado,
			ISNULL(CONCAT(PV.RazonSocial ,' ', ISNULL(PV.RegimenCapital,'')),A.IdProveedor) AS Cliente,
			AC.IdAceptacionCartaPCN,
			ISNULL(TV.TipoValidacion,'Sin iniciar aprobación')	AS EstatusAprobacion
         FROM dbo.MPY_MM_AceptacionPedido AS A		 
		 LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido	AND ISNULL(AC.IdEstatusEliminado,0)<> 1 --> OCULTAR ACCN CON ESTATUS DE ELIMINACION LOGICA =1
		 LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus
		 LEFT JOIN dbo.S_Proveedor AS PV ON PV.RFC = A.IdProveedor AND PV.Activo = 1
         WHERE A.IdSubcontratista = @IdProveedor
		 AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN 
										  FROM dbo.MPY_MM_AceptacionCartaPCN A_PCN 
										  WHERE A_PCN.IdAceptacionPedido=A.IdAceptacionPedido 
										  ORDER BY A_PCN.CreadoEl DESC) 
			  OR AC.IdAceptacionCartaPCN IS NULL
		 ) 
		 AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO 
		 AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA		 
		 GROUP BY 		
		 A.IdAceptacionPedido,
		 A.IdPedido,
		 A.Creado,
		 A.NombreUsuarioEntrega,
		 PV.RazonSocial,
		 PV.RegimenCapital,
		 A.IdProveedor,
		 AC.IdAceptacionCartaPCN,
		 TV.TipoValidacion,
		 A.IdEstatusEliminado
		 ORDER BY A.IdAceptacionPedido DESC


       END  

  END;
