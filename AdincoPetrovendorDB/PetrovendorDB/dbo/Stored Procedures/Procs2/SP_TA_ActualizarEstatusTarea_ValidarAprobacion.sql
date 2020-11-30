-- =============================================
-- Author:		Daniel AC
-- Create date: 08/09/2020
-- Description: Validar que la tarea esta activa para aprobación
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ActualizarEstatusTarea_ValidarAprobacion]
    @IdOperacion INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @IdTarea INT,
            @IdEstatusTarea INT,           
            @NoSecuencia INT,
            @NoSecuenciaActual INT;


    --SE OBTIENE EL TIPO DE FLUJO(SERIAL O PARALELO)

    DECLARE @IdTipoFlujo INT;

    SELECT @IdTipoFlujo = FT.IdTipoFlujo
    FROM dbo.TA_Operacion O (NOLOCK)
        INNER JOIN TA_FlujoTarea FT (NOLOCK)
            ON O.IdFlujoTarea = FT.IdFlujoTarea
    WHERE IdOperacion = @IdOperacion;


    /*OBTENER EL ID DE LA TAREA DEL USUARIO ACTUAL*/

    SELECT @IdTarea = T.IdTarea,
           @IdEstatusTarea = T.IdEstatus,
           @NoSecuencia = T.NoSecuencia
    FROM TA_Tarea AS T (NOLOCK)
    WHERE T.IdAprobador = @IdUsuario
          AND T.IdOperacion = @IdOperacion;

    DECLARE @IdAprobadorActualFlujo INT;

	IF ISNULL(@IdTarea,0) =0	
	BEGIN 
		SELECT 'ERROR','No se encontró el registro de la aprobación solicitada'
		RETURN
	END	
		
    --SE VALIDA QUE EL SIGUIENTE APROBADOR SE EL MISMO AL QUE DESEA APROBAR
    IF @IdEstatusTarea = 1 --> SI ES UNO ESTA AUN EN APROBACIÓN DE LO CONTRARIO YA FUE EVALUADA
    BEGIN
        IF @IdTipoFlujo = 1 --> ES TIPO DE APROBACIÓN ES SERIAL
        BEGIN
            SELECT TOP 1
                   @IdAprobadorActualFlujo = IdAprobador,
                   @NoSecuenciaActual = NoSecuencia
            FROM dbo.TA_Tarea (NOLOCK)
            WHERE IdEstatus = 1 --> EN APROBACIÓN 
                  AND IdOperacion = @IdOperacion
                  AND Activo = 1
            ORDER BY NoSecuencia ASC;

            IF @IdAprobadorActualFlujo = @IdUsuario
                SELECT 'SUCCESS',
                       'Continuar con la aprobación de la tarea';
            ELSE
            BEGIN
                DECLARE @NOMBRE_APROBADOR NVARCHAR(MAX);
                SELECT @NOMBRE_APROBADOR = Nombre
                FROM dbo.S_Usuario (NOLOCK)
                WHERE IdUsuario = @IdAprobadorActualFlujo;
                SELECT 'ERROR',
                       CONCAT(
                                 'La aprobación es serial, el aprobador actual es ',
                                 @NOMBRE_APROBADOR,
                                 ' con el número de secuencia ',
                                 @NoSecuenciaActual, ' para realizar la aprobación, es necesario esperar tu turno'
                             );
            END;
        END;
        ELSE
        BEGIN
            SELECT 'SUCCESS',
                   'Continuar con la aprobación de la tarea';
        END;
    END;
    ELSE
    BEGIN
        DECLARE @NOMBRE_ESTATUS NVARCHAR(MAX);
        SELECT @NOMBRE_ESTATUS = Nombre
        FROM dbo.TA_Estatus
        WHERE IdEstatus = @IdEstatusTarea;
        SELECT 'ERROR',
               CONCAT('La aprobación ya tiene una acción realizada por tu usuario, con un estatus: ', ISNULL(@NOMBRE_ESTATUS, ''));
    END;

END;