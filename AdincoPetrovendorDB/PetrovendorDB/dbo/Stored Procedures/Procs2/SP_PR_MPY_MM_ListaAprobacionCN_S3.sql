
-- =============================================
-- Author:		DANIEL AC
-- Update date: 07/02/2018
-- Description:	agregue filtro para todos los estatus de carta de contenido nacional y cambio tipo pedido
-- Author:		DANIEL AC
-- Update date: 01/06/2018
-- Description:	Se agrego condicion solo mostrar aquellas aprobaciones con aceptacion de carta de contenido nacional diferente a estatus eliminado =!
-- =============================================

-- [SP_PR_MPY_MM_ListaAprobacionCN_S3] 10037,0
CREATE procedure [dbo].[SP_PR_MPY_MM_ListaAprobacionCN_S3] 
	-- Add the parameters for the stored procedure here
@IdContrato NVARCHAR(MAX)=10037,
@Estado INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

	 IF @Estado IN (1,2,3) 
	 BEGIN
		SELECT 
			AC.IdAceptacionCartaPCN, 
			AC.IdAceptacionPedido, 
			AP.IdPedido, 
			AC.IdDocumento, 
			AC.CreadoEl,
			ISNULL(SPV.VendorName,PR.RazonSocial) AS Proveedor,			 
			TD.TipoValidacion
		FROM dbo.MPY_MM_AceptacionPedido AS AP 
		LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		LEFT JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		LEFT JOIN [dbo].[S_Proveedor] AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
		LEFT JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SPV ON  SPV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE 
		AP.IdContrato = @IdContrato
		--AND AC.IdAceptacionCartaPCN IS NOT NULL
		AND AC.IdEstatus = @Estado
		AND ISNULL(AC.IdEstatusEliminado,0) <> 1  --> QUE NO ESTEN ELIMINADOS
		ORDER BY  Ac.IdAceptacionPedido desc

     END;

	 IF @Estado = 0  ---TODOS
	 BEGIN	     
	
        SELECT 
			AC.IdAceptacionCartaPCN, 
			AC.IdAceptacionPedido, 
			AP.IdPedido, 
			AC.IdDocumento, 
			AP.Creado AS CreadoEl,
			ISNULL(SPV.VendorName,PR.RazonSocial) AS Proveedor,			 
			ISNULL(TD.TipoValidacion, 'Sin Iniciar Aprobación') AS TipoValidacion
		FROM dbo.MPY_MM_AceptacionPedido AS AP 
		 JOIN dbo.MPY_MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		LEFT JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		LEFT JOIN [dbo].[S_Proveedor] AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
		LEFT JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SPV ON  SPV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE 
		AP.IdContrato = 10037
		--AND AC.IdAceptacionCartaPCN IS NOT NULL
		AND ISNULL(AC.IdEstatusEliminado,0) <> 1  --> QUE NO ESTEN ELIMINADOS
		ORDER BY  AP.Creado DESC

     END;

END

