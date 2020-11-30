-- =============================================
-- Author:		Oscar Mtz
-- Create date: 07/07/2017
-- Description:	Actualiza la tabla AP_PerfilUsuario en base al usuarioId y Objeto JSON que recibe como parametro.
-- =============================================
CREATE PROCEDURE dbo.sp_AP_UpdatePerfilUsuario
@UsuarioId as int,
@PerfilIDList as varchar(max),
@CreadoPor as int=0
AS
BEGIN 
DECLARE @RowAffected as int=0;
SET NOCOUNT ON;
	BEGIN TRY
		
		DECLARE @RandomUpdate as INT;
		DECLARE 				
		@item varchar(800), 
		@Pos int

		--Obtenemos unnumero aleatorio en base a un rango.
		SET @RandomUpdate = (SELECT dbo.Fn_ObtenerNumeroAleatorio(1,999));

		IF(@RandomUpdate >0)
		BEGIN
			--Se asigna el RandomUpdate
			UPDATE [dbo].[AP_PerfilUsuario] SET RandomUpdate = @RandomUpdate WHERE UsuarioID= @UsuarioId;
		
			IF(LEN(@PerfilIDList) > 1)
			BEGIN		 		 
				SET @PerfilIDList = LTRIM(RTRIM(@PerfilIDList))+ ','
				SET @Pos = CHARINDEX(',', @PerfilIDList, 1)

				WHILE @Pos > 0
				BEGIN
					SET @item = LTRIM(RTRIM(LEFT(@PerfilIDList, @Pos - 1)))
					IF @item <> ''
					BEGIN
						--PRINT('@item: ' + @item);				
						INSERT INTO [dbo].[AP_PerfilUsuario] (UsuarioID, PerfilID, CreadoPor)
						VALUES (@UsuarioId, CAST(@item AS INT), @CreadoPor);

						SET @RowAffected += @@ROWCOUNT;
					END
					SET @PerfilIDList = RIGHT(@PerfilIDList, LEN(@PerfilIDList) - @Pos)
					SET @Pos = CHARINDEX(',', @PerfilIDList, 1)
				END
			END
		 		 		 		 		   
			--Filas afectadas.
			----SELECT @RowAffected = @@ROWCOUNT			
			SELECT @RowAffected as FilasAfectadas;

			--Se borran los datos asignados con el valor de Random generado.
			DELETE FROM [dbo].[AP_PerfilUsuario]  WHERE RandomUpdate= @RandomUpdate;
						
		END
		ELSE
		BEGIN
			SELECT   
			'0' AS NumeroError  				
			,'sp_AP_UpdatePerfilUsuario' AS ProcedimientoError  
			,'' AS LineaError  
			,'No fue posible actualizar el perfil.' AS MensajeError;		  
		END
	END TRY
	BEGIN CATCH
	SELECT   
	ERROR_NUMBER() AS NumeroError  				
	,ERROR_PROCEDURE() AS ProcedimientoError  
	,ERROR_LINE() AS LineaError  
	,ERROR_MESSAGE() AS MensajeError;
	END CATCH
END

