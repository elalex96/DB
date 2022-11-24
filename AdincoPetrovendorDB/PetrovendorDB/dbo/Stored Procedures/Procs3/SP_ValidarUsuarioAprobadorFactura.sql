-- =============================================  
-- Author:  Daniel AC   
-- Create date: 09/10/2020  
-- Description: Validar si el usuario actual es aprobador de la factura actual  
-- =============================================  
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins 
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarUsuarioAprobadorFactura]
    @IdUsuario INT,
    @IdOperacion INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;

    DECLARE @TipoFlujoAprobacion INT;
    DECLARE @IdFlujoAprobacion INT;
    DECLARE @IdEstatusUsuarioAnteriorSecuencia INT;
    DECLARE @NoSecuenciaUsuarioActual INT;
    DECLARE @NoSecuenciaAprobadorAnterior INT;

    SELECT @IdFlujoAprobacion = IdFlujoTarea
    FROM dbo.TA_Operacion
    WHERE IdOperacion = @IdOperacion;

    SELECT @TipoFlujoAprobacion = IdTipoFlujo
    FROM dbo.TA_FlujoTarea (NOLOCK)
    WHERE IdFlujoTarea = @IdFlujoAprobacion;


    IF @TipoFlujoAprobacion = 1 --> ES FLUJO SERIAL  
    BEGIN

        ---OBTENER EL NUMERO DE SECUENCIA DEL USUARIO ACTUAL SI ES APROBADOR DEL FLUJO SERIAL  
        SELECT @NoSecuenciaUsuarioActual = TT.NoSecuencia
        FROM TA_OPERACION O
            JOIN TA_Tarea TT
                ON O.IdOperacion = TT.IdOperacion
        WHERE O.IdOperacion = @IdOperacion
              AND TT.IdAprobador = @IdUsuario
              AND TT.Activo = 1;

        ---OBTENER EL ESTATUS DEL APROBADOR ANTERIOR   
        --- ESTO ES PARA BLOQUEAR BOTONES DE APROBACIÓN SI LA APROBACIÓN ES DE TIPO SERIAL  
        SELECT @IdEstatusUsuarioAnteriorSecuencia = TT.IdEstatus,
               @NoSecuenciaAprobadorAnterior = TT.NoSecuencia
        FROM TA_OPERACION O
            JOIN TA_Tarea TT
                ON O.IdOperacion = TT.IdOperacion
        WHERE O.IdOperacion = @IdOperacion
              AND TT.NoSecuencia = (ISNULL(@NoSecuenciaUsuarioActual, 0) - 1)
              AND TT.Activo = 1;

    END;

    SELECT 'ES_APROBADOR',                                                     ---0  
           TT.IdEstatus,                                                       ---1  
           TT.NoSecuencia,                                                     ---2  
           @TipoFlujoAprobacion AS TipoFlujoAprobacion,                        ---3,  
           ISNULL(@IdEstatusUsuarioAnteriorSecuencia, 0) AS IdEstatusAnterior, ---4  
           ISNULL(@NoSecuenciaAprobadorAnterior, 0) AS NoSecuenciaAnterior     ---5  
    FROM TA_Operacion O
        JOIN TA_Tarea TT
            ON O.IdOperacion = TT.IdOperacion
    WHERE O.IdOperacion = @IdOperacion
          AND TT.IdAprobador = @IdUsuario
          AND TT.Activo = 1;

END;
