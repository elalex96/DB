CREATE TABLE [dbo].[S_Contacto] (
    [IdContacto]       INT           IDENTITY (1, 1) NOT NULL,
    [IdTipoContacto]   INT           NULL,
    [Nombres]          NVARCHAR (50) NULL,
    [Apellidos]        NVARCHAR (50) NULL,
    [Email]            NVARCHAR (50) NULL,
    [Telefono]         NVARCHAR (20) NULL,
    [IsPredeterminado] BIT           NULL,
    [IdProveedor]      INT           NULL,
    [IsEliminado]      BIT           NULL,
    CONSTRAINT [PK_S_Contacto] PRIMARY KEY CLUSTERED ([IdContacto] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdTipoContacto]) REFERENCES [dbo].[S_TipoContacto] ([IdTipoContacto]),
    FOREIGN KEY ([IdTipoContacto]) REFERENCES [dbo].[S_TipoContacto] ([IdTipoContacto]),
    FOREIGN KEY ([IdTipoContacto]) REFERENCES [dbo].[S_TipoContacto] ([IdTipoContacto]),
    FOREIGN KEY ([IdTipoContacto]) REFERENCES [dbo].[S_TipoContacto] ([IdTipoContacto]),
    CONSTRAINT [FK__S_Contact__IdPro__51BA1E3A] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);


GO
-- =============================================
-- Author: Manuel Cruz
-- Create date: 9-02-17
-- Description:	
-- =============================================


CREATE TRIGGER [dbo].[Trigger_PredeterminarContacto] ON [dbo].[S_Contacto]
AFTER INSERT, UPDATE
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @predeterminado BIT;
         DECLARE @idproveedor INT;
         DECLARE @IdContacto INT;
         DECLARE @IdTipoContacto INT;
         
	    -- Insert statements for trigger here

	    SELECT @predeterminado = IsPredeterminado,
                @idproveedor = IdProveedor,
                @IdTipoContacto = IdTipoContacto,
			 @IdContacto = IdContacto
         FROM inserted;
         
	    --verifica si el idcontacto es nulo (insert)
         IF(isnull(@IdContacto, 0) = 0)
             BEGIN
                 SELECT @IdContacto = @@IDENTITY;
             END;
         
	    IF @IdTipoContacto = 1
            AND @predeterminado = 1
             BEGIN
                 UPDATE dbo.S_Contacto
                   SET
                       IsPredeterminado = 0
                 WHERE IdProveedor = @idproveedor
                       AND IdContacto <> @IdContacto
                       AND IdTipoContacto = @IdTipoContacto;
             END;

         IF @IdTipoContacto = 2
            AND @predeterminado = 1
             BEGIN
                 UPDATE dbo.S_Contacto
                   SET
                       IsPredeterminado = 0
                 WHERE IdProveedor = @idproveedor
                       AND IdContacto <> @IdContacto
                       AND IdTipoContacto = @IdTipoContacto;
             END;
     END;