USE [Adinco]
GO
DROP PROCEDURE IF EXISTS sp_JOB_CreaAlertasInstancias
GO
-- =============================================  
-- Author:  Daniel AC
-- Create date: 19/06/2025  
-- Description: SE RETORNA TABLA PARA ENVIO DE CORREOS CON DOBLE AUTENTIFICACIÓN
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_JOB_CreaAlertasInstancias]
AS
BEGIN
    -- =============================================
    -- Author:		Reyna Olvera
    -- Create date: 20181023
    -- Description:	Crea Alertas 
    -- =============================================
    -- 20190701	BAAC	Se modifica para que no inserte los registros para el push de la aplicación, solo las notificaciones de correo.
    -- =============================================
    SET NOCOUNT ON;
	CREATE TABLE #TemporalCorreosUsuario (  
		Para VARCHAR(500),  
		Asunto VARCHAR(500),  
		Mensaje NVARCHAR(MAX),  
		De VARCHAR(200),
		CreadoPor INT
	);  

    DECLARE @HOY DATE,
            @NombreDia VARCHAR(100);
    SET @HOY = GETDATE();
    SELECT @NombreDia = NombreDia
    FROM dbo.AP_Calendario
    WHERE IdFecha = @HOY;

	IF @NombreDia = 'Lunes'
	BEGIN
		INSERT INTO #TemporalCorreosUsuario (   
										Para,
                                        Asunto,
                                        Mensaje,                                       
                                        CreadoPor
                                      ) 
		EXEC sp_EN_NotificacionesSemanales
		INSERT INTO #TemporalCorreosUsuario (   
										Para,
                                        Asunto,
                                        Mensaje,                                       
                                        CreadoPor
                                      ) 
		EXEC sp_EN_NotificacionesSemanales_ENI
	END

	IF (@NombreDia NOT IN ( 'Sábado', 'Domingo' ))
	BEGIN
		INSERT INTO #TemporalCorreosUsuario (   
										Para,
                                        Asunto,
                                        Mensaje,                                       
                                        CreadoPor
                                      ) 
		EXEC sp_EN_NotificacionesDiarias_Equinor
	END

	UPDATE #TemporalCorreosUsuario 
	SET Mensaje = REPLACE(Mensaje,N'&copy; 2019, Todos los derechos reservados',CONCAT('&copy; ',FORMAT(GETDATE(),'yyyy'),', Todos los derechos reservados'))
	
	SELECT 
	Para,
	Asunto,
	Mensaje,
	CreadoPor
	FROM #TemporalCorreosUsuario
END;
