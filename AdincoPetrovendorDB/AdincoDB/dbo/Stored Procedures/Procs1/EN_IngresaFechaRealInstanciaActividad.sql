-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20190720
-- Description:Guarda Fecha real Actividad
-- =============================================
CREATE PROCEDURE [dbo].[EN_IngresaFechaRealInstanciaActividad] -- 3,10061,11309,'20190301'--SIMULACION 
    @idContrato INT,
    @idUsuario INT,
    @idInstanciaActividad INT,
    @FechaRealInstanciaActividad DATE
AS
BEGIN

    DECLARE @error VARCHAR(500) = '',
            @countEntregablesPendientes INT = 0;

    SELECT @countEntregablesPendientes = COUNT(1) 
    FROM dbo.EN_InstanciasEntregables_InstanciaActividad IEIA
    JOIN dbo.EN_InstanciasActividades IA ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
                                            AND IA.idInstanciaActividad = @idInstanciaActividad
    JOIN dbo.EN_InstanciasEntregable IE ON IEIA.idInstanciaEntregable = IE.idInstanciaEntregable
    JOIN dbo.EN_Actividad A ON IE.ActividadID = A.ActividadID
                               AND A.EstadoID <> 10003 
	WHERE	IE.Activo	=	1
	AND IEIA.Activo	=	1
	AND	IA.Activo	=	1
    GROUP BY IE.idInstanciaEntregable,
             IE.ActividadID,
             A.EstadoID;

    IF (@countEntregablesPendientes = 0)
    BEGIN
        UPDATE dbo.EN_InstanciasActividades
        SET FechaRealActividad = @FechaRealInstanciaActividad
        WHERE idInstanciaActividad = @idInstanciaActividad;
        IF @@ERROR <> 0
        BEGIN
            SET @error = CAST(@@ERROR AS NVARCHAR(8));
        END;
    END;
    ELSE
    BEGIN
        SET @error
            = 'No puede ingresar fecha real de esta actividad, ya que existen ' + LTRIM(@countEntregablesPendientes)
              + ' entregables pendientes';
    END;
    SELECT @error
	 AS ERROR;
END;

