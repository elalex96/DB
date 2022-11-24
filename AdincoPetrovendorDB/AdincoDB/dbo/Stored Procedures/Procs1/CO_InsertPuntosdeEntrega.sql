CREATE PROCEDURE [dbo].[CO_InsertPuntosdeEntrega]
	@Nombre				NVARCHAR(Max),
	@TagPatinMedicion	NVARCHAR(100),
	@TipoMedidor		NVARCHAR(100),
	@TagMedidor			NVARCHAR(100),
	@Clasificacion		NVARCHAR(100),
	@IdentificacionResponsable		VARCHAR(150),
	@Coordenadas		VARCHAR(150),
	@Latitud		VARCHAR(150),
	@Longitud  VARCHAR(150),
	@idUsuario			INT=0,
	@idContrato			INT =0
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/18
-- Description:	inserta al catalogo de puntos de entrega 
-- =============================================
-- 20180504	BAAC	Se modifica para agregar mas campos a la tabla por reportes de la CNH
-- =============================================
	SET NOCOUNT ON
-- =============================================
	DECLARE @cont INT;
	SELECT @cont=COUNT(puntoEntregaID) FROM  CO_PuntosdeEntrega 
	WHERE Nombre = LTRIM(RTRIM(@Nombre))

	IF(@cont>=1)
	BEGIN
		--SE VALIDA SI EL PUNTO QUE YA EXISTE ESTA INACTIVO, EN ESE CASO SE HABILITA, EN CASO CONTRARIO; SE ENVIA MENSAJE
		IF 0 < (SELECT COUNT(1) FROM  CO_PuntosdeEntrega WHERE Nombre = @Nombre AND Activo = 0)
		BEGIN
			UPDATE	dbo.CO_PuntosdeEntrega
				SET Activo = 1
			WHERE	Nombre = LTRIM(RTRIM(@Nombre))
				AND Activo	=	0
		END
		ELSE
		BEGIN
			PRINT('Ya hay un punto de entrega parecido.')
		END
	END
	ELSE
	BEGIN
		INSERT INTO CO_PuntosdeEntrega
		(Nombre, TagPatinMedicion, TipoMedidor, TagMedidor, Clasificacion, Activo, CreadoPor, CreadoEl, IdentificacionResponsable,Coordenadas,Latitud,Longitud  )
		VALUES (LTRIM(RTRIM(@Nombre)), LTRIM(RTRIM(@TagPatinMedicion)), LTRIM(RTRIM(@TipoMedidor)), LTRIM(RTRIM(@TagMedidor)), LTRIM(RTRIM(@Clasificacion)), 1, @idUsuario, GETDATE(), LTRIM(RTRIM(@IdentificacionResponsable)),LTRIM(RTRIM(@Coordenadas)),LTRIM(RTRIM(@Latitud)),LTRIM(RTRIM(@Longitud)))
	END
END


