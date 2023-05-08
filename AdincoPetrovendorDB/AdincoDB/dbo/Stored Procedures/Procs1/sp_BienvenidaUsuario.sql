-- Author:      Pedro A
-- Create date: 21-07-2017
-- Description: Se busca al usuario y se extrae los datos del usuario, ademas se reemplazan los ## de la tabla [S_Correo]
--por los datos del usuario, se utiliza como filtro el Asunto ya que el idCorreo es autoincrementable entonces no se sabe que id se asignara
--Modificado: Reyna Olvera
--date:15/03/2018
-- =============================================
CREATE PROCEDURE [dbo].[sp_BienvenidaUsuario]--10061
(@idUsuario INT)
AS
BEGIN
    DECLARE @asunto VARCHAR(50) = 'Bienvenida al sistema',
            @bienvenido NVARCHAR(150) = N'Bienvenido,',
            @usuario NVARCHAR(150) = N'Su usuario es: ',
            @passw NVARCHAR(150) = N'Su contraseña es: ',
            @Ruta NVARCHAR(150) = N'Ingrese a http://',
            @bienvenidoEN NVARCHAR(150) = N'Welcome, ',
            @usuarioEN NVARCHAR(150) = N'Your user is: ',
            @passwEN NVARCHAR(150) = N'Your password is: ',
            @RutaEN NVARCHAR(150) = N'Enter to http://';

    DECLARE @tabla TABLE
    (
        usuario NVARCHAR(150),
        contraseña NVARCHAR(150),
        nombre NVARCHAR(150),
        cuerpo1 NVARCHAR(MAX),
        cuerpo2 NVARCHAR(MAX),
        Ruta NVARCHAR(MAX),
        id INT
    );
    INSERT INTO @tabla
    (
        usuario,
        contraseña,
        nombre,
        id,
        Ruta
    )
    SELECT Usuario,
           Contraseña,
           Nombre,
           @idUsuario,
           Ruta
    FROM AP_Usuario U
        LEFT JOIN AP_Rutas R
            ON U.idRuta = R.idRuta
    WHERE UsuarioID = @idUsuario;
    --Se actualiza la tabla a retornar para reemplpazar los ## por el texto a mostrar
    UPDATE @tabla
    SET cuerpo1 = REPLACE(
                             REPLACE(
                                        REPLACE(
                                                   REPLACE(
                                                              REPLACE(
                                                                         REPLACE(
                                                                                    REPLACE(
                                                                                               REPLACE(
                                                                                                          correo.Cuerpo1,
                                                                                                          '##BienvenidoEN##',
                                                                                                          @bienvenidoEN
                                                                                                          + nombre
                                                                                                      ),
                                                                                               '##UsuarioEN##',
                                                                                               @usuarioEN + usuario
                                                                                           ),
                                                                                    '##ContraseñaEN##',
                                                                                    @passwEN + contraseña
                                                                                ),
                                                                         '##RutaEN##',
                                                                         @RutaEN + Ruta
                                                                     ),
                                                              '##Bienvenido',
                                                              @bienvenido + nombre
                                                          ),
                                              '##Usuario',
                                                   @usuario + usuario
                                               ),
                                        '##Contraseña',
                                        @passw + contraseña
                                    ),
                             '##Ruta',
                             @Ruta + Ruta
                         ),
        cuerpo2 = correo.Cuerpo2
    --SELECT *
    FROM S_Correo correo
    WHERE Asunto = @asunto; --/Welcome to system
    SELECT *
    FROM @tabla;
END;
    
    
  
  

