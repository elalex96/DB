USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_ActividadxGrupoCBSH_MV1_5
GO
-- =============================================
-- Author:		<Alexander G>
-- Create date: <27/07/2017>
-- Description:	<Procedimiento para crear tabla para obtener las actividades correspondientes a un grupo especifico>
-- ============================================
-- Author:		<Jose Roman>
-- Create date: <13-09-2018>
-- Description:	<Se muestra el codigo SE>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/05/2019>
-- Description:	<Se agrego la agrupacion de campos para evitar duplicacion>
-- =============================================
-- Author:		Luis David
-- Create date: <02/09/2022>
-- Description:	<Se optimiza para el Issue #1986>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActividadxGrupoCBSH_MV1_5]
    --@IdGrupoCBSH INT
    /*--------------------
    parametros contrato
  --------------------*/
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
/*--------------------
  --------------------*/
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.IdActividad,
           A.Nombre AS TipoActividad,
           G.Nombre AS Grupo,
		   A.Codigo
    FROM dbo.MM_BS_Actividad (NOLOCK) A
        INNER JOIN dbo.MM_BS_Grupo (NOLOCK) G
            ON A.IdGrupo = G.IdGrupo
	GROUP BY A.IdActividad,
             A.Nombre,
             G.Nombre,
             A.Codigo
    ORDER BY A.IdActividad ASC;
END;
