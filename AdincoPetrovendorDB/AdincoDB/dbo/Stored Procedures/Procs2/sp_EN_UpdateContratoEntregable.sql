DROP PROCEDURE IF EXISTS sp_EN_UpdateContratoEntregable
GO
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama las rondas
--=============================================
-- Author:		Reyna Olvera
-- UPDATE date: 20190522
-- Description:SE AGREGO BIT INTERNO
-- ==========================================
-- Author:		Reyna Olvera
-- UPDATE date: 20200218
-- Description:SE AGREGaron nuevas columnas de shell y repsol
-- ==========================================
-- Author:		Reyna Olvera
-- UPDATE date: 20200326
-- Description:Se comento el apartado dé entregable interno, ya que tambien pueden agregar fechas, en caso de que no se mecesite proceso
-- ==========================================
-- Author:		Luis David
-- UPDATE date: 17/11/2021
-- Description:	Se actualiza el bit awareness para issue Adinco/adinco-entregables/issues/473
-- ==========================================
CREATE PROCEDURE [dbo].[sp_EN_UpdateContratoEntregable]
    @idContrato INT,
    @idUsuario INT,
    @idArea INT,
    @DiasElaboracion INT,
    @DiasRevision INT,
    @DiasAprobacion INT,
    @DiasAlerta INT,
    @ReceptorAlerta NVARCHAR(MAX),
    @Activo BIT,
    @FechaLimiteEntrega DATE,
    @FechaLimiteEntregaRegulador DATE,
    @IdContratoEntregable INT,
    @BitInterno INT,
	@Subfuncion VARCHAR(500),
    @FocalPoint VARCHAR(500),
    @AccountableCompliance VARCHAR(500),
    @Accountable VARCHAR(500),
	@ContieneFechaInterna INT,
	@ContieneFechaRegulador INT,
	@ContieneInformacionSensible BIT,
	@BitAwareness BIT = NULL
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @CountInstRevAprob	INT,
            @Error				NVARCHAR(MAX),
			@IdEntregable		INT;


    SELECT @CountInstRevAprob = COUNT(*)
      FROM dbo.EN_InstanciasEntregable ie
      JOIN dbo.EN_Actividad a
        ON a.ActividadID          = ie.ActividadID
       AND a.IdContratoEntregable = ie.IdContratoEntregable
       AND EstadoID IN ( 10001, 10002 )
     WHERE ie.IdContratoEntregable = @IdContratoEntregable;

       /* IF (@BitInterno = 0)
        BEGIN*/
            UPDATE EN_ContratoEntregable
               SET IdArea = @idArea,
                   DiasElaboracion = @DiasElaboracion,
                   DiasRevision = @DiasRevision,
                   DiasAprobacion = @DiasAprobacion,
                   DiasAlerta = @DiasAlerta,
                   ReceptorAlerta = @ReceptorAlerta,
                   ModificadoPor = @idUsuario,
                   ModificadoEl = GETDATE(),
                   Activo = @Activo,
                   FechaLimiteEntrega =
					   CASE @ContieneFechaInterna
						   WHEN 0
						   THEN NULL
						   ELSE  @FechaLimiteEntrega
					   END,
                   FechaLimiteEntregaRegulador =    
					   CASE @ContieneFechaRegulador
						   WHEN 0
						   THEN NULL
						   ELSE  @FechaLimiteEntregaRegulador
					   END,
				   Subfuncion= REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@Subfuncion)),CHAR(9),''),CHAR(10),''),CHAR(13),''),
				   FocalPoint = REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@FocalPoint)),CHAR(9),''),CHAR(10),''),CHAR(13),''),
				   AccountableCompliance = REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@AccountableCompliance)),CHAR(9),''),CHAR(10),''),CHAR(13),''),
				   Accountable = REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@Accountable)),CHAR(9),''),CHAR(10),''),CHAR(13),''),
				   ContieneInformacionSensible=@ContieneInformacionSensible
             WHERE IdContratoEntregable =  @IdContratoEntregable;
       /* END;
        IF (@BitInterno = 1)
        BEGIN
            UPDATE EN_ContratoEntregable
               SET IdArea = @idArea,
                   DiasElaboracion = @DiasElaboracion,
                   DiasRevision = @DiasRevision,
                   DiasAprobacion = @DiasAprobacion,
                   DiasAlerta = @DiasAlerta,
                   ReceptorAlerta = @ReceptorAlerta,
                   ModificadoPor = @idUsuario,
                   ModificadoEl = GETDATE(),
                   Activo = @Activo,
				   Subfuncion= REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@Subfuncion)),CHAR(9),''),CHAR(10),''),CHAR(13),''),
				   FocalPoint = REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@FocalPoint)),CHAR(9),''),CHAR(10),''),CHAR(13),''),
				   AccountableCompliance = REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@AccountableCompliance)),CHAR(9),''),CHAR(10),''),CHAR(13),''),
				   Accountable = REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(@Accountable)),CHAR(9),''),CHAR(10),''),CHAR(13),''),
				   ContieneInformacionSensible=@ContieneInformacionSensible
             WHERE IdContratoEntregable = @IdContratoEntregable;
        END;
   */
	IF @BitInterno = 1 
	BEGIN
		IF @BitAwareness IS NOT NULL 
		BEGIN 
			SET @IdEntregable = (select e.IdEntregable from EN_ContratoEntregable ce
							join EN_Entregable e
							on ce.IdEntregable = e.IdEntregable
							where IdContratoEntregable = @IdContratoEntregable)
			UPDATE EN_Entregable 
			SET BitAwareness = @BitAwareness
			WHERE IdEntregable = @IdEntregable
		END
	END
    IF (@CountInstRevAprob > 0)
    BEGIN
        SET @Error = N'NOHAYERROR: Existen '+LTRIM(@CountInstRevAprob)+' entregables pendientes de Revisar/Aprobar, a los cuales se aplicó el mismo cambio.';
    END;

    SELECT @Error AS error;
END;
