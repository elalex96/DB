/****** Object:  StoredProcedure [dbo].[SP_PR_GuardaInst_Pozo]    Script Date: 25/02/2019 09:18:14 a. m. ******/
-- =============================================
-- Author:		Reynha Olvera
-- Create date: <Create Date,,>
-- Description:Guarda Pozo
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_GuardaInst_Pozo]
    -- Add the parameters for the stored procedure here
    @IdContrato INT,
    @IdUsuario INT,
    @IdInstalacion INT,
    @NombreInstalacion NVARCHAR(MAX),
    @Clave NVARCHAR(MAX),
    @IdCampo INT,
    @RegionFiscal NVARCHAR(MAX),
    @TipoFluidoPetroleo NVARCHAR(MAX),
    @TipoFluidoGas NVARCHAR(MAX),
    @PuntoEntregaID INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @IdPozo         INT,
            @CountInstaPozo INT;

    SELECT @CountInstaPozo = COUNT(IdInstalacion)
      FROM dbo.CO_Instalacion
     WHERE NombreInstalacion = @NombreInstalacion;
    IF (@CountInstaPozo <= 1)
    BEGIN
        IF 0 = (SELECT COUNT(Id) FROM dbo.PR_Pozo WHERE Nombre = @NombreInstalacion)
        BEGIN
            INSERT INTO dbo.PR_Pozo (Clave,
                                     Nombre,
                                     Descripcion,
                                     Estatus,
                                     LDD,
                                     Estacion,
                                     Campo,
                                     ProduccionNeta,
                                     Tanque,
                                     UltimoControl,
                                     SubEstado,
                                     TipoProduccion,
                                     ActividadIncremental,
                                     TipoSistema,
                                     PozoTipo,
                                     Modificado,
                                     ModificadoPor,
                                     ModificadoServer,
                                     Alta,
                                     Comentarios,
                                     AnioActividad,
                                     UltimoControlValido,
                                     ProduccionBruta,
                                     PorcentajeAgua,
                                     X,
                                     Y,
                                     PotencialOperativo,
                                     PotencialOptimo,
                                     OFM,
                                     RegionFiscal,
                                     TipoFluidoPetroleo,
                                     TipoFluidoGas,
                                     PuntoEntregaID)
            VALUES (@Clave, -- Clave - varchar(20)
                    UPPER(@NombreInstalacion), -- Nombre - varchar(200)
                    UPPER(CONCAT('POZO ', REPLACE(@NombreInstalacion, 'pozo ', ''))), -- Descripcion - nvarchar(2000)
                    1, -- Estatus - int
                    NULL, -- LDD - tinyint
                    NULL, -- Estacion - int
                    @IdCampo, -- Campo - int
                    NULL, -- ProduccionNeta - decimal(24, 8)
                    NULL, -- Tanque - int
                    NULL, -- UltimoControl - datetime
                    NULL, -- SubEstado - int
                    NULL, -- TipoProduccion - int
                    NULL, -- ActividadIncremental - int
                    NULL, -- TipoSistema - int
                    NULL, -- PozoTipo - int
                    NULL, -- Modificado - datetime
                    NULL, -- ModificadoPor - varchar(200)
                    NULL, -- ModificadoServer - datetime
                    GETDATE(), -- Alta - datetime
                    N'', -- Comentarios - nvarchar(max)
                    NULL, -- AnioActividad - int
                    NULL, -- UltimoControlValido - int
                    NULL, -- ProduccionBruta - decimal(24, 8)
                    NULL, -- PorcentajeAgua - decimal(8, 4)
                    0, -- X - float
                    0, -- Y - float
                    NULL, -- PotencialOperativo - decimal(24, 8)
                    NULL, -- PotencialOptimo - decimal(24, 8)
                    '', -- OFM - varchar(20)
                    @RegionFiscal, -- RegionFiscal - nvarchar(100)
                    @TipoFluidoPetroleo, -- TipoFluidoPetroleo - nvarchar(150)
                    @TipoFluidoGas, -- TipoFluidoGas - nvarchar(150)
                    @PuntoEntregaID -- PuntoEntregaID - int
                );
            SELECT @IdPozo = Id
              FROM dbo.PR_Pozo
             WHERE Nombre = @NombreInstalacion;
            IF 0 = (   SELECT COUNT(IdInstalacion)
                         FROM dbo.CO_Instalacion
                        WHERE WelIID = @IdPozo)
            BEGIN
                UPDATE dbo.CO_Instalacion
                   SET WelIID = @IdPozo
                 WHERE IdInstalacion = @IdInstalacion;
            END;
            IF @@ERROR <> 0
                SELECT 'false' AS msj;
            ELSE
                SELECT '' AS msj;
        END;
        ELSE
        BEGIN
            SELECT @IdPozo = Id
              FROM dbo.PR_Pozo
             WHERE Nombre = @NombreInstalacion;

            IF 0 = (   SELECT COUNT(IdInstalacion)
                         FROM dbo.CO_Instalacion
                        WHERE WelIID = @IdPozo)
            BEGIN
                UPDATE dbo.CO_Instalacion
                   SET WelIID = @IdPozo
                 WHERE IdInstalacion = @IdInstalacion;
            END;

            IF @@ERROR <> 0
                SELECT 'false' AS msj;
            ELSE
                SELECT '' AS msj;
        END;
    END;
    ELSE
    BEGIN
        SELECT 'Existen más instalaciónes con el mismo nombre, por favor reporte a Soporte Adinco' AS msj;
    END;
END;
