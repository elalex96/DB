CREATE TABLE [dbo].[AP_MenuN] (
    [MenuId]        INT            IDENTITY (1, 1) NOT NULL,
    [Clave]         NVARCHAR (MAX) NULL,
    [visible]       BIT            NULL,
    [idClasMenu]    INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    [archivo]       NVARCHAR (MAX) NULL,
    [menupadre]     INT            NULL,
    [descripcion]   VARCHAR (MAX)  NULL,
    [Orden]         INT            NULL,
    [HTML]          NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([MenuId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__AP_MenuN__idClas__493C48D7] FOREIGN KEY ([idClasMenu]) REFERENCES [dbo].[AP_ClasificacionMenu] ([idClasMenu])
);


GO
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 21/01/2018
-- Description:	Inserta nuevas opciones de menu en cada rol
-- =============================================
CREATE TRIGGER [dbo].[tr_ActualizaMenuPorRol]
ON [dbo].[AP_MenuN]
AFTER INSERT, update
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    INSERT INTO dbo.AP_MenuPorRol
    (
        IdRol,
        IdMenu,
        Visible
    )
    SELECT R.IdRol,
           M.MenuId,
           0 AS Visible
    FROM dbo.AP_Rol R
        CROSS JOIN dbo.AP_MenuN M
        LEFT JOIN dbo.AP_MenuPorRol MR
            ON MR.IdMenu = M.MenuId
               AND R.IdRol = MR.IdRol
    WHERE MR.IdMenu IS NULL;

-- Insert statements for trigger here

END;
