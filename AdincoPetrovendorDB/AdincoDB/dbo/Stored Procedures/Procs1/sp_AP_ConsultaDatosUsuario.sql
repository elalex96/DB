-- =============================================
-- Author:		Miguel Gomez
-- Create date: 20-01-2018
-- Description:	Obtiene la informacion del usuario
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ConsultaDatosUsuario] 
	-- Add the parameters for the stored procedure here
@Usuario    NVARCHAR(MAX),
@IdUsuario  INT,
@IdContrato INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT UsuarioID,
                    Usuario,
                    Contraseña,
                    Nombre,
                    IsActivo,
                    fchRegistro,
                    IsEliminado,
                    imgsrc,
                    UltimoAcceso,
                    Idioma,
                    CreadoPor,
                    IdTipoUsuario,
                    Sello,
                    image,
                    Foto,
                    ModificadoPor,
                    ModificadoEl,
                    TFAuthentication,
                    NumeroCelular,
                    P.CodigoPais AS CodigoPais
             FROM AP_Usuario
                  LEFT JOIN dbo.AP_Paises P ON dbo.AP_Usuario.CodigoPais = p.idPais
             WHERE(Usuario = @Usuario);
         END;
