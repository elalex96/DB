USE Petrovendor
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ActividadxGrupoCBSH_MV1_5_CN_OCD'
)
    DROP PROCEDURE SP_ActividadxGrupoCBSH_MV1_5_CN_OCD;
GO
-- =============================================
-- Author:		<Alexander G>
-- Create date: <27/07/2017>
-- Description:	<Procedimiento para crear tabla para obtener las actividades correspondientes a un grupo especifico>
-- ============================================
-- Author:		<Daniel>
-- Create date: <12-11-2025>
-- Description:	<Se muestra el codigo SE y se agrupa información>
-- =============================================

CREATE PROCEDURE [dbo].[SP_ActividadxGrupoCBSH_MV1_5_CN_OCD] 

    @IdContrato INT,
    @IdUsuario INT = null,
    @FechaRegistro DATETIME = null

AS
BEGIN
    SET NOCOUNT ON;
	CREATE TABLE #DATOS(
	 IdActividad INT,
	 TipoActividad NVARCHAR(600),
	 Grupo NVARCHAR(600),
	 Codigo NVARCHAR(200)
	)

	INSERT INTO #DATOS(
	  IdActividad,
	  TipoActividad,
	  Grupo,
	  Codigo
	)
    SELECT A.IdActividad,
           A.Nombre AS TipoActividad,
           G.Nombre AS Grupo,
		   A.Codigo
    FROM dbo.MM_BS_Actividad A
        INNER JOIN dbo.MM_BS_Grupo G
            ON G.IdGrupo = A.IdGrupo
	GROUP BY 
	A.IdActividad,
    A.Nombre,
    G.Nombre,
	A.Codigo
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

	SELECT 
	IdActividad,
    TipoActividad AS TipoActividad,
    Grupo AS Grupo,
	Codigo
    FROM #DATOS
END;

