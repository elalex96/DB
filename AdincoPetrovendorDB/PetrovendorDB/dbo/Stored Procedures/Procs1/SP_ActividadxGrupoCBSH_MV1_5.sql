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
    FROM dbo.MM_BS_Actividad A
        INNER JOIN dbo.MM_BS_Grupo G
            ON G.IdGrupo = A.IdGrupo
	GROUP BY A.IdActividad,
             A.Nombre,
             G.Nombre,
             A.Codigo
    ORDER BY A.IdActividad ASC;
END;
