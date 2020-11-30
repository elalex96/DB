-- =============================================
-- Author:  	Reyna Olvera
-- Create date: 20191029
-- Description:	extrae cat de procesos
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_InsertUpdateCatProcesos]--3,10061,'B','Proceso para el  Registro del Generador de Residuos Peligrosos',0
@IdContrato int,
@IdUsuario int,
@Nombre varchar(max),
@Descripcion varchar(max),
@IdCatProceso int
AS
BEGIN
  IF (@IdCatProceso = 0)
  BEGIN
    DECLARE @Clave varchar(150),
            @IdCatProcesoMAX int;
    SELECT  @IdCatProcesoMAX = ISNULL(MAX(IdCatProceso), 0)
    FROM EN_CatalogoProcesos;

    IF (@IdCatProcesoMAX = 0)
    BEGIN
      SET @Clave = 'ADINCO-PRO001';
    END
    ELSE
    BEGIN
      SELECT
        @Clave = 'ADINCO-PRO' +
		 CASE LEN(LTRIM(CONVERT(int, SUBSTRING(+Clave, 11, LEN(Clave))) + 1))
			WHEN 1
				THEN  '00'+ LTRIM(CONVERT(int, SUBSTRING(+Clave, 11, LEN(Clave))) + 1)
			WHEN 2
				THEN '0'+ LTRIM(CONVERT(int, SUBSTRING(+Clave, 11, LEN(Clave))) + 1)
			ELSE
				LTRIM(CONVERT(int, SUBSTRING(+Clave, 11, LEN(Clave))) + 1) 
		END
      FROM dbo.EN_CatalogoProcesos
      WHERE IdCatProceso = @IdCatProcesoMAX;
    END
		IF((SELECT COUNT(1) FROM EN_CatalogoProcesos WHERE Nombre=@Nombre)=0)
			BEGIN
				INSERT INTO dbo.EN_CatalogoProcesos (Nombre, Descripcion, clave, CreadoPor, CreadoEn)
				  VALUES (@Nombre,      -- Nombre - varchar(max)
				  @Descripcion, -- Descripcion - varchar(max)
				  @Clave,       -- clave - varchar(150)
				  @IdUsuario,   -- CreadoPor - int
				  GETDATE()     -- CreadoEn - datetime
				  );

				INSERT INTO EN_Procesos (NombreProceso,
				Descripcion,
				CreadoPor,
				CreadoEl,
				Activo,
				idTipoProceso,
				IsProcesoEvento,
				IsSerie,
				Clave)
				  SELECT
					@Nombre,
					NumeroContrato,
					@IdUsuario,
					GETDATE(),
					1,
					10000,
					1,
					1,
					@Clave
				  FROM CO_Contrato
				  WHERE fechaFirma IS NOT NULL
				  AND IdRonda IS NOT NULL

				INSERT INTO EN_ProcesosContrato (idContrato, idProceso, CreadoPor, CreadoEn, Activo)
				  SELECT
					IdContrato,
					IdProceso,
					@IdUsuario,
					GETDATE(),
					1
				  FROM EN_Procesos P
				  JOIN CO_Contrato C
					ON P.Descripcion = C.NumeroContrato
					AND C.fechaFirma IS NOT NULL
					AND IdRonda IS NOT NULL

				INSERT INTO EN_ProcesosRondas (IdProceso, IdRonda, CreadoPor, CreadoEl, Activo)
				  SELECT
					IdProceso,
					IdRonda,
					@IdUsuario,
					GETDATE(),
					1
				  FROM EN_Procesos P
				  JOIN CO_Contrato C
					ON P.Descripcion = C.NumeroContrato
					AND C.fechaFirma IS NOT NULL
					AND IdRonda IS NOT NULL

				UPDATE EN_Procesos
				SET Descripcion = @Descripcion
				WHERE NombreProceso = @Nombre
			END
			ELSE
			BEGIN 
				SELECT 'Ya existe un proceso con el mismo nombre' as error;
			END
  END;
  ELSE
  BEGIN
    UPDATE EN_CatalogoProcesos
    SET Nombre = @Nombre,
        Descripcion = @Descripcion,
        ModificadoPor = @IdUsuario,
        ModificadoEn = GETDATE()
    WHERE IdCatProceso = @IdCatProceso;
  END;

END;

 