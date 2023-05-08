CREATE PROCEDURE [dbo].[SP_BitacoraError]
(@HResult     INT,
 @Mensaje     NVARCHAR(MAX),
 @StackTrace  NVARCHAR(MAX),
 @IdUsuario   INT,
 @IdProveedor INT
)
AS
         BEGIN
             DECLARE @valorInsertado INT;
             INSERT INTO AP_BitacoraErrores
(HResult,
 Mensaje,
 StackTrace,
 IdUsuario,
 IdContrato,
 FechaRegistro
)
             VALUES
(@HResult, -- HResult - int
 @Mensaje, -- Mensaje - nvarchar(max)
 @StackTrace, -- StackTrace - nvarchar(max)
 @IdUsuario, -- IdUsuario - int
 @IdProveedor,
 GETDATE()
);
             SELECT @valorInsertado = @@IDENTITY;
             SELECT CONCAT(CONVERT(NVARCHAR(255), ABS(@HResult)), '-', IdError)
             FROM AP_BitacoraErrores
             WHERE IdError = @valorInsertado;
         END;

