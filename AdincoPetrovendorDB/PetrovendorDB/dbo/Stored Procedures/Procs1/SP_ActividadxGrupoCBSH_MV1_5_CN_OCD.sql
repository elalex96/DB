-- =============================================
-- Author:		<Alexander G>
-- Create date: <27/07/2017>
-- Description:	<Procedimiento para crear tabla para obtener las actividades correspondientes a un grupo especifico>
-- ============================================
-- Author:		<Jose Roman>
-- Create date: <13-09-2018>
-- Description:	<Se muestra el codigo SE>
-- =============================================

CREATE PROCEDURE [dbo].[SP_ActividadxGrupoCBSH_MV1_5_CN_OCD] --3
    --@IdGrupoCBSH INT
    /*--------------------
    parametros contrato
  --------------------*/
    @IdContrato INT,
    @IdUsuario INT = null,
    @FechaRegistro DATETIME = null
/*--------------------
  --------------------*/
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.IdActividad,
           A.Nombre AS TipoActividad,
           G.Nombre AS Grupo,
		   A.Codigo
	INTO #DATOS
    FROM dbo.MM_BS_Actividad A
        INNER JOIN dbo.MM_BS_Grupo G
            ON G.IdGrupo = A.IdGrupo
    ORDER BY A.IdActividad ASC;

	INSERT INTO #DATOS
	(
	    IdActividad,
	    TipoActividad,
	    Grupo,
	    Codigo
	)
	VALUES
	(   0,   -- IdActividad - int
	    'NO CONTENIDO', -- TipoActividad - nvarchar(300)
	    'NO CONTENIDO', -- Grupo - nvarchar(300)
	    'NO CONTENIDO'  -- Codigo - nvarchar(100)
	    )

	SELECT * FROM #DATOS
END;