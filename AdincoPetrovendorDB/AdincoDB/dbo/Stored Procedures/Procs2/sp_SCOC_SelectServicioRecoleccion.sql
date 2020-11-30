CREATE PROCEDURE dbo.sp_SCOC_SelectServicioRecoleccion
    @idContrato INT,
    @idUsuario INT,
    @MesReporte DATE
AS
BEGIN
    -- =============================================
    -- Author:		Reyna Olvera
    -- Create date: 2019/02/14
    -- Description:	Select reporte de Recoleccion de BN
    -- =============================================
    SET NOCOUNT ON;
    SET LANGUAGE SPANISH;

    SELECT MesReporte,
           Observaciones,
       --    TotalBN,
           FechaElaboracion,
           FechaEntrega,
           Firma_GCHC,
           Firma_Conformidad
      FROM SCOC_RecoleccionBN_Historial
     WHERE IdContrato = @idContrato
       AND MesReporte = @MesReporte



END

