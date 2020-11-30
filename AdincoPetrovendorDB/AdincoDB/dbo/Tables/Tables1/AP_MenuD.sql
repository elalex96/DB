CREATE TABLE [dbo].[AP_MenuD] (
    [MenuId]          INT           IDENTITY (1, 1) NOT NULL,
    [Orden]           INT           NULL,
    [ElementId]       VARCHAR (250) NULL,
    [Class]           VARCHAR (100) NULL,
    [InnerHtml]       VARCHAR (250) NULL,
    [Url]             VARCHAR (350) NULL,
    [MenuPadreId]     INT           NULL,
    [Visible]         BIT           NULL,
    [MenuNId]         INT           NULL,
    [InnerHtmlIngles] VARCHAR (250) NULL,
    CONSTRAINT [PK_AP_MenuD] PRIMARY KEY CLUSTERED ([MenuId] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 21/01/2018
-- Description:	Inserta nuevas opciones de menu en cada rol
-- =============================================
create TRIGGER [dbo].[tr_ActualizaMenuDPorRol]
ON [dbo].[AP_MenuD]
AFTER INSERT, update
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    INSERT INTO dbo.AP_MenuDPorRol
    (
        IdRol,
        IdMenu,
        Visible
    )
    SELECT R.IdRol,
           M.MenuId,
           0 AS Visible
    FROM dbo.AP_Rol R
        CROSS JOIN dbo.AP_MenuD M
        LEFT JOIN dbo.AP_MenuDPorRol MR
            ON MR.IdMenu = M.MenuId
               AND R.IdRol = MR.IdRol
    WHERE MR.IdMenu IS NULL;

-- Insert statements for trigger here

END;
