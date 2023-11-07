IF EXISTS
(
    SELECT 1
    FROM sysobjects
    WHERE name = 'SP_FI_ProveedoresConOperaciones'
)
    DROP PROCEDURE SP_FI_ProveedoresConOperaciones;
GO

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
    @IdContrato INT,
    @IdUsuario INT,
    @FactComp INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    IF OBJECT_ID('tempdb..#TemporalContratos', 'U') IS NOT NULL
        DROP TABLE #TemporalContratos;

    --
    DECLARE @IdContratista INT;

    --
    CREATE TABLE #TemporalContratos (IdContrato INT);

    --
    SET @IdContratista =
    (
        SELECT IdContratista
        FROM CO_Contrato (NOLOCK)
        WHERE IdContrato = @IdContrato
    );

    /*Contratistas Jaguar*/
    IF (@IdContratista = 10005 OR @IdContratista = 10006)
    BEGIN
        INSERT INTO #TemporalContratos
        (
            IdContrato
        )
        SELECT IdContrato
        FROM CO_Contrato (NOLOCK)
        WHERE IdContratista IN ( 10005, 10006 )
              AND ISNULL(Activo, 0) = 1;
    END;
    /*Todos los demas Contratista*/
    ELSE
    BEGIN
        INSERT INTO #TemporalContratos
        (
            IdContrato
        )
        SELECT IdContrato
        FROM CO_Contrato (NOLOCK)
        WHERE IdContratista = @IdContratista
              AND ISNULL(Activo, 0) = 1;
    END;

    /*Selección  de Proveedores por Contratos*/
    /*Por Facturas*/
    IF (@FactComp = 0)
    BEGIN
        SELECT PV_Subcontratista.IdSubcontratista,
               CASE
                   WHEN ISNULL(PV_Subcontratista.RFC, '') = '' THEN
                       UPPER(ISNULL(PV_Subcontratista.RazonSocial, ''))
                   WHEN ISNULL(PV_Subcontratista.RazonSocial, '') = '' THEN
                       UPPER(ISNULL(PV_Subcontratista.RFC, ''))
                   ELSE
                       UPPER(CONCAT(ISNULL(PV_Subcontratista.RazonSocial, ''), ' - ', ISNULL(PV_Subcontratista.RFC, '')))
               END AS RazonSocial,
               ISNULL(PV_Subcontratista.RFC, '') AS RFC
        FROM #TemporalContratos
            INNER JOIN FI_Factura (NOLOCK)
                ON #TemporalContratos.IdContrato = FI_Factura.IdContrato
            INNER JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
                   AND ISNULL(PV_Subcontratista.IsEliminado, 0) = 0
                   AND ISNULL(PV_Subcontratista.IsActivo, 0) = 1
        GROUP BY PV_Subcontratista.IdSubcontratista,
                 CASE
                     WHEN ISNULL(PV_Subcontratista.RFC, '') = '' THEN
                         UPPER(ISNULL(PV_Subcontratista.RazonSocial, ''))
                     WHEN ISNULL(PV_Subcontratista.RazonSocial, '') = '' THEN
                         UPPER(ISNULL(PV_Subcontratista.RFC, ''))
                     ELSE
                         UPPER(CONCAT(
                                         ISNULL(PV_Subcontratista.RazonSocial, ''),
                                         ' - ',
                                         ISNULL(PV_Subcontratista.RFC, '')
                                     )
                              )
                 END,
                 PV_Subcontratista.RFC
        ORDER BY CASE
                     WHEN ISNULL(PV_Subcontratista.RFC, '') = '' THEN
                         UPPER(ISNULL(PV_Subcontratista.RazonSocial, ''))
                     WHEN ISNULL(PV_Subcontratista.RazonSocial, '') = '' THEN
                         UPPER(ISNULL(PV_Subcontratista.RFC, ''))
                     ELSE
                         UPPER(CONCAT(
                                         ISNULL(PV_Subcontratista.RazonSocial, ''),
                                         ' - ',
                                         ISNULL(PV_Subcontratista.RFC, '')
                                     )
                              )
                 END;
    END;
    /*Por Complementos*/
    ELSE
    BEGIN
        SELECT PV_Subcontratista.IdSubcontratista,
               CASE
                   WHEN ISNULL(PV_Subcontratista.RFC, '') = '' THEN
                       UPPER(ISNULL(PV_Subcontratista.RazonSocial, ''))
                   WHEN ISNULL(PV_Subcontratista.RazonSocial, '') = '' THEN
                       UPPER(ISNULL(PV_Subcontratista.RFC, ''))
                   ELSE
                       UPPER(CONCAT(ISNULL(PV_Subcontratista.RazonSocial, ''), ' - ', ISNULL(PV_Subcontratista.RFC, '')))
               END AS RazonSocial,
               ISNULL(PV_Subcontratista.RFC, '') AS RFC
        FROM #TemporalContratos
            INNER JOIN FI_Factura (NOLOCK)
                ON #TemporalContratos.IdContrato = FI_Factura.IdContrato
                   AND FI_Factura.TipoComprobante = 'P'
            INNER JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
                   AND ISNULL(PV_Subcontratista.IsEliminado, 0) = 0
                   AND ISNULL(PV_Subcontratista.IsActivo, 0) = 1
        GROUP BY PV_Subcontratista.IdSubcontratista,
                 CASE
                     WHEN ISNULL(PV_Subcontratista.RFC, '') = '' THEN
                         UPPER(ISNULL(PV_Subcontratista.RazonSocial, ''))
                     WHEN ISNULL(PV_Subcontratista.RazonSocial, '') = '' THEN
                         UPPER(ISNULL(PV_Subcontratista.RFC, ''))
                     ELSE
                         UPPER(CONCAT(
                                         ISNULL(PV_Subcontratista.RazonSocial, ''),
                                         ' - ',
                                         ISNULL(PV_Subcontratista.RFC, '')
                                     )
                              )
                 END,
                 PV_Subcontratista.RFC
        ORDER BY CASE
                     WHEN ISNULL(PV_Subcontratista.RFC, '') = '' THEN
                         UPPER(ISNULL(PV_Subcontratista.RazonSocial, ''))
                     WHEN ISNULL(PV_Subcontratista.RazonSocial, '') = '' THEN
                         UPPER(ISNULL(PV_Subcontratista.RFC, ''))
                     ELSE
                         UPPER(CONCAT(
                                         ISNULL(PV_Subcontratista.RazonSocial, ''),
                                         ' - ',
                                         ISNULL(PV_Subcontratista.RFC, '')
                                     )
                              )
                 END;
    END;
END;