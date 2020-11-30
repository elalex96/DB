-- =============================================
-- Author:		Marcos Garcia
-- Create Date: 05-12-2019
-- Description:	Seleccion de Proveedores con 
--				Operaciones realizadas en los contratos.
-- =============================================
-- Author:		Marcos Garcia
-- Alter Date:  06-01-2020
-- Description:	Se agrega RFC en la Razon Social
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ProveedoresConOperaciones] 
-- [SP_FI_ProveedoresConOperaciones] 3, 10002,0
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT, 
@FactComp   INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         --==================== IdContratista del Contrato ================
         DECLARE @IdContratista INT;
         --=========================
         SET @IdContratista =
         (
             SELECT IdContratista
             FROM dbo.CO_Contrato
             WHERE IdContrato = @IdContrato
         );
         --============== Contratos Relacionados al Contratista ===========
         IF OBJECT_ID('tempdb..#ContratosTempo', 'U') IS NOT NULL
             DROP TABLE #ContratosTempo;
         --=============================
         CREATE TABLE #ContratosTempo
         (IdContrato INT
         );
         --=============================
         --Contratistas Jaguar
         IF(@IdContratista = 10005
            OR @IdContratista = 10006)
		
             BEGIN
                 INSERT INTO #ContratosTempo(IdContrato)
                        SELECT IdContrato
                        FROM dbo.CO_Contrato
                        WHERE IdContratista IN(10005, 10006)
                        AND Activo = 1;
             END; 
         --Todos los demas Contratista         
		ELSE        
             BEGIN
                 INSERT INTO #ContratosTempo(IdContrato)
                        SELECT IdContrato
                        FROM dbo.CO_Contrato
                        WHERE IdContratista = @IdContratista
                              AND Activo = 1;
             END;

         --=========== Seleccion de Proveedores por Contratos ============== 
         --======= Por Facturas =======		
         IF(@FactComp = 0)
             BEGIN
                 SELECT SC.IdSubcontratista, 
				UPPER(CONCAT(SC.RazonSocial,' - ', SC.RFC)) AS RazonSocial,                         
                        SC.RFC

                 FROM dbo.FI_Factura F
                      LEFT JOIN Adinco.dbo.PV_Subcontratista SC ON SC.IdSubcontratista = F.IdSubcontratista
                      INNER JOIN #ContratosTempo T ON F.IdContrato = T.IdContrato
                 WHERE ISNULL(SC.IsEliminado, 0) = 0
                       AND ISNULL(SC.IsActivo, 0) = 1
                 GROUP BY UPPER(CONCAT(SC.RazonSocial,' - ', SC.RFC)),
                          SC.IdSubcontratista,
                          SC.RFC
                 ORDER BY UPPER(CONCAT(SC.RazonSocial,' - ', SC.RFC));
             END;
         --===== Por Complementos =====			
         IF(@FactComp <> 0)
             BEGIN
                 SELECT SC.IdSubcontratista, 
				 UPPER(CONCAT(SC.RazonSocial,' - ', SC.RFC)) AS RazonSocial,                         
                        SC.RFC
                 FROM dbo.FI_Factura F
                      LEFT JOIN Adinco.dbo.PV_Subcontratista SC ON SC.IdSubcontratista = F.IdSubcontratista
                      INNER JOIN #ContratosTempo T ON F.IdContrato = T.IdContrato
                 WHERE ISNULL(SC.IsEliminado, 0) = 0
                       AND ISNULL(SC.IsActivo, 0) = 1
                       AND F.TipoComprobante = 'P'
                GROUP BY UPPER(CONCAT(SC.RazonSocial,' - ', SC.RFC)),
                         SC.IdSubcontratista,
                         SC.RFC
                 ORDER BY UPPER(CONCAT(SC.RazonSocial,' - ', SC.RFC));
             END;
     END;