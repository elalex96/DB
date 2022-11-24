CREATE PROCEDURE [dbo].[SP_EN_EniInstanciasExterno]
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-03-2020
-- Description:	Instancias de entregables para acceso aplicacion externa
-- =============================================
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT --E.IdEntregable, 
        IE.idInstanciaEntregable, 
        DocumentoEntregable, 
        ISNULL(MarcoLegal, '') AS MarcoLegal, 
        ISNULL(Articulo, '') AS Articulo, 
        ISNULL(R.Regulador, '') AS Regulador, 
        ISNULL(f.FrecuenciaEntregable, 'Entregable Interno') AS FrecuenciaEntregable, 
        E.Consecutivo, 
        MAX(HALT.IdLineaTiempo) AS Versionn
    --SELECT * 
    FROM dbo.EN_InstanciasEntregable IE
        JOIN dbo.EN_ContratoEntregable CE ON IE.IdContratoEntregable = CE.IdContratoEntregable
        JOIN dbo.EN_Entregable E ON CE.IdEntregable = E.IdEntregable
		AND E.BITJOA = 0
        JOIN dbo.EN_HistorialAprobacionesLineaTiempo HALT ON IE.idInstanciaEntregable = HALT.idInstanciaEntregable
                                                            AND HALT.Rechazado = 0
        LEFT JOIN dbo.EN_MarcoLegal ML ON E.IdMarcoLegal = ML.IdMarcoLegal
        LEFT JOIN dbo.EN_FrecuenciaEntregable f ON E.IdFrecuenciaEntregable = f.IdFrecuenciaEntregable
        LEFT JOIN dbo.CO_Regulador R ON E.IdRegulador = R.IdRegulador
    WHERE CE.IdContrato = @IdContrato
    --AND IE.idInstanciaEntregable = 92219
    GROUP BY ISNULL(MarcoLegal, ''), 
            ISNULL(Articulo, ''), 
            ISNULL(R.Regulador, ''), 
            ISNULL(f.FrecuenciaEntregable, 'Entregable Interno'), 
            --E.IdEntregable, 
            IE.idInstanciaEntregable, 
            E.DocumentoEntregable, 
            E.Consecutivo;
END;