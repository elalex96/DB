/****** Object:  StoredProcedure [dbo].[sp_AP_ListaOpcionesCombo]    Script Date: 15/04/2019 10:11:39 p. m. ******/
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	Lista las opciones para un combo
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ListaOpcionesCombo] -- 3,2,'ENAP'
    -- Add the parameters for the stored procedure here
    @IdContrato INT = 0,
    @IdUsuario INT = 0,
    @ClaveGrupo NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    CREATE TABLE #Lista
    (
        idLista INT,
        idClave INT,
        Nombre NVARCHAR(MAX)
    );

    INSERT INTO #Lista
    (
        idLista,
        idClave,
        Nombre
    )
    SELECT AP_Lista.IdLista,
           AP_Lista.IdClave,
           CASE AP_Lista.Nombre
               WHEN 'Todos' THEN
                   '1-Todos'
               ELSE
                   AP_Lista.Nombre
           END AS Nombre
    FROM AP_Lista
        INNER JOIN AP_Grupo
            ON AP_Lista.IdGrupo = AP_Grupo.IdGrupo
    WHERE (AP_Grupo.ClaveGrupo = @ClaveGrupo)
          AND AP_Lista.Activo = 1
    ORDER BY AP_Lista.Nombre;

    SELECT *
    FROM #Lista
    ORDER BY Nombre ASC;

END;
