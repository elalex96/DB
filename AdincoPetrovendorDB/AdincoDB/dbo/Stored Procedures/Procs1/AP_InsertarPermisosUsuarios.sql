-- ================================================
CREATE PROCEDURE [dbo].[AP_InsertarPermisosUsuarios]
    -- Add the parameters for the stored procedure here
    @UsuarioID AS INT,
    @IdPermiso AS INT,
    @BitActivo AS BIT,
    @IdContrato AS INT,     -- Contrato Seleccionado
    @IdUsuario AS INT,      -- Session
    @IdContratoSession INT, --Session
    @cont INT
AS
BEGIN
    -- ==========================================================
    -- Author:		Valeria Rodríguez
    -- Create date: 18/02/2019
    -- Description:	Inserta datos en la tabla AP_PermisosUsuarios
    -- ==========================================================
 
    SET NOCOUNT ON;
    --IF (@IdContrato = 0)
    --BEGIN
    --    SELECT @IdContrato = IdContrato
    --    FROM dbo.CO_Contrato
    --    WHERE NumeroContrato = 'CNH-M1-EK-BALAM/2017';
    --END;

	SET @IdContrato=@IdContratoSession;-- para que lo asigne al contrato en el que esta logueado el usuario
    IF (@cont = 1)
    BEGIN
        DELETE FROM AP_PermisosUsuarios
        WHERE UsuarioID = @UsuarioID AND idContrato=@IdContrato
    END;

    --SELECT *
    --FROM dbo.CO_Contrato
    --WHERE NumeroContrato = '';

    INSERT INTO AP_PermisosUsuarios
    (
        UsuarioID,
        IdPermiso,
        BitActivo,
        idContrato
    )
    VALUES
    (@UsuarioID, @IdPermiso, @BitActivo, @IdContrato);
END;
--SELECT * FROM AP_PermisosUsuarios WHERE UsuarioID=10061

